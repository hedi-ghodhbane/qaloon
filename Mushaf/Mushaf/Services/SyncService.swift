import Foundation
import Observation

/// Keeps the reader's state in step between devices through a **sync code**
/// (no account): one device creates a code on the Ertak server, the others
/// enter it. See `src/lib/mushaf-sync.ts` for the protocol.
///
/// The service watches the UserDefaults keys the views already use
/// (`@AppStorage`), stamps a field with the time it changed on this device and
/// sends everything with one `PUT`; the server merges per field (newest wins)
/// and answers with the result, which is written back to UserDefaults — the
/// views follow on their own. Sending stale values is harmless, so syncing is
/// simply "PUT what I have, adopt what comes back".
@MainActor
@Observable
final class SyncService {
    static let shared = SyncService()

    enum Status: Equatable {
        case idle, syncing
        case failed(String)
    }

    /// Canonical 10-character code; empty = sync is off on this device.
    private(set) var code: String
    private(set) var status: Status = .idle
    private(set) var lastSync: Date?

    var isOn: Bool { !code.isEmpty }

    /// "ABCDE-FGHJK"
    var displayCode: String {
        code.count == 10 ? "\(code.prefix(5))-\(code.suffix(5))" : code
    }

    // MARK: - Synced fields

    private enum Value: Equatable {
        case int(Int), bool(Bool), string(String)

        var json: Any {
            switch self {
            case .int(let v): return v
            case .bool(let v): return v
            case .string(let v): return v
            }
        }
    }

    /// UserDefaults key (same name on the wire) and the default the views use.
    private static let fields: [(key: String, fallback: Value)] = [
        ("lastPage", .int(1)),
        ("progressAyah", .int(0)),
        ("hideMode", .bool(false)),
        ("keepMarkers", .bool(true)),
        ("autoAdvance", .bool(true)),
        ("reciter", .string(Reciters.defaultId)),
        ("repeatCount", .int(1)),
    ]

    @ObservationIgnored private let defaults = UserDefaults.standard
    /// Last value seen per field (local or adopted), to tell real changes from our own writes.
    @ObservationIgnored private var known: [String: Value] = [:]
    /// Epoch milliseconds each field last changed.
    @ObservationIgnored private var stamps: [String: Double] = [:]
    @ObservationIgnored private var observer: NSObjectProtocol?
    @ObservationIgnored private var pushTask: Task<Void, Never>?
    @ObservationIgnored private var started = false

    private var baseURL: URL {
        // `-syncBaseURL http://localhost:3000` as a launch argument points a build at a dev server.
        URL(string: defaults.string(forKey: "syncBaseURL") ?? "") ?? URL(string: "https://ertak.makeathar.com")!
    }

    private init() {
        code = UserDefaults.standard.string(forKey: "sync.code") ?? ""
        stamps = (UserDefaults.standard.dictionary(forKey: "sync.stamps") as? [String: Double]) ?? [:]
        let saved = UserDefaults.standard.dictionary(forKey: "sync.known") ?? [:]
        for field in Self.fields {
            if let value = Self.value(saved[field.key], like: field.fallback) { known[field.key] = value }
        }
    }

    /// Call once from the root view: starts watching local changes and syncs.
    func start() {
        guard !started else { return }
        started = true
        observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.noteLocalChanges() }
        }
        Task {
            // `-syncJoin CODE` links a fresh install from the command line (testing, provisioning).
            if !isOn, let pending = defaults.string(forKey: "syncJoin"), !pending.isEmpty {
                await join(pending)
            } else {
                noteLocalChanges()
                await syncNow()
            }
        }
    }

    // MARK: - Actions

    /// Start a new group with this device's state; the server answers with the code.
    func create() async {
        let now = Self.nowMs()
        for field in Self.fields {
            known[field.key] = current(field)
            stamps[field.key] = now
        }
        guard let state = await send("POST", path: "/api/mushaf-sync", payload: statePayload()) else { return }
        guard let newCode = state.code else {
            status = .failed("ردّ غير متوقع من الخادم.")
            return
        }
        code = newCode
        persist()
        finish(adopting: state.fields)
    }

    /// Link this device to an existing group. Its own values carry stamp 0, so the group's win.
    func join(_ input: String) async {
        let cleaned = input.uppercased().filter { $0.isLetter || $0.isNumber }
        guard cleaned.count == 10 else {
            status = .failed("الرمز يتكوّن من عشرة أحرف وأرقام.")
            return
        }
        for field in Self.fields {
            known[field.key] = current(field)
            stamps[field.key] = 0
        }
        guard let state = await send("PUT", path: "/api/mushaf-sync/\(cleaned)", payload: statePayload()) else { return }
        code = cleaned
        persist()
        finish(adopting: state.fields)
    }

    func syncNow() async {
        guard isOn, status != .syncing else { return }
        guard let state = await send("PUT", path: "/api/mushaf-sync/\(code)", payload: statePayload()) else { return }
        finish(adopting: state.fields)
    }

    /// Stop syncing on this device (the group and the other devices are untouched).
    func disconnect() {
        pushTask?.cancel()
        code = ""
        stamps = [:]
        known = [:]
        lastSync = nil
        status = .idle
        persist()
    }

    // MARK: - Local changes

    private func noteLocalChanges() {
        guard isOn else { return }
        var changed = false
        for field in Self.fields {
            let now = current(field)
            if known[field.key] != now {
                known[field.key] = now
                stamps[field.key] = Self.nowMs()
                changed = true
            }
        }
        guard changed else { return }
        persist()
        // Debounce: flipping through pages should not mean a request per page.
        pushTask?.cancel()
        pushTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(1500))
            guard !Task.isCancelled else { return }
            await self?.syncNow()
        }
    }

    private func finish(adopting remote: [String: (Value, Double)]) {
        for field in Self.fields {
            guard let (value, stamp) = remote[field.key] else { continue }
            let local = stamps[field.key] ?? 0
            guard stamp > local || (stamp == local && known[field.key] != value) else { continue }
            // Record first, then write: the change notification then finds nothing new.
            known[field.key] = value
            stamps[field.key] = stamp
            if current(field) != value { defaults.set(value.json, forKey: field.key) }
        }
        persist()
        lastSync = Date()
        status = .idle
    }

    // MARK: - Plumbing

    private func current(_ field: (key: String, fallback: Value)) -> Value {
        Self.value(defaults.object(forKey: field.key), like: field.fallback) ?? field.fallback
    }

    private static func value(_ raw: Any?, like kind: Value) -> Value? {
        guard let raw else { return nil }
        switch kind {
        case .int:
            if let n = raw as? NSNumber { return .int(n.intValue) }
            if let s = raw as? String, let n = Int(s) { return .int(n) }
        case .bool:
            if let b = raw as? Bool { return .bool(b) }
            if let s = raw as? String { return .bool((s as NSString).boolValue) }
        case .string:
            if let s = raw as? String { return .string(s) }
        }
        return nil
    }

    private static func nowMs() -> Double {
        (Date().timeIntervalSince1970 * 1000).rounded()
    }

    private func persist() {
        defaults.set(code, forKey: "sync.code")
        defaults.set(stamps, forKey: "sync.stamps")
        defaults.set(known.mapValues(\.json), forKey: "sync.known")
    }

    private func statePayload() -> [String: Any] {
        var state: [String: Any] = [:]
        for field in Self.fields {
            state[field.key] = ["v": (known[field.key] ?? current(field)).json, "t": stamps[field.key] ?? 0]
        }
        return ["state": state]
    }

    private struct Reply {
        let code: String?
        let fields: [String: (Value, Double)]
    }

    private func send(_ method: String, path: String, payload: [String: Any]) async -> Reply? {
        status = .syncing
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let http = response as? HTTPURLResponse
            guard let http, (200..<300).contains(http.statusCode) else {
                status = .failed(http?.statusCode == 404
                    ? "لا توجد مجموعة مزامنة بهذا الرمز."
                    : "تعذّرت المزامنة (\(http?.statusCode ?? 0)).")
                return nil
            }
            guard let body = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let state = body["state"] as? [String: Any] else {
                status = .failed("ردّ غير متوقع من الخادم.")
                return nil
            }
            var fields: [String: (Value, Double)] = [:]
            for field in Self.fields {
                guard let entry = state[field.key] as? [String: Any],
                      let value = Self.value(entry["v"], like: field.fallback),
                      let stamp = (entry["t"] as? NSNumber)?.doubleValue else { continue }
                fields[field.key] = (value, stamp)
            }
            return Reply(code: body["code"] as? String, fields: fields)
        } catch {
            status = .failed("لا اتصال بالخادم؛ ستُعاد المحاولة عند فتح التطبيق.")
            return nil
        }
    }
}
