import Foundation

/// Qaloun recitation: MP3Quran hosts full-surah MP3s for a few Qaloun reciters
/// together with an ayah timing API, so the player streams the surah file and
/// seeks to the ayah window (same approach as Ertak's web reader).
struct Reciter: Identifiable, Hashable {
    let id: String
    let nameAr: String
    let nameEn: String
    /// `${base}001.mp3` … `${base}114.mp3`
    let base: String
    /// MP3Quran `read` id for /api/v3/ayat_timing; nil = whole-surah playback only.
    let timingRead: Int?

    var timed: Bool { timingRead != nil }

    func surahURL(_ surah: Int) -> URL {
        URL(string: base + String(format: "%03d.mp3", surah))!
    }
}

enum Reciters {
    static let all: [Reciter] = [
        Reciter(id: "husary", nameAr: "محمود خليل الحصري", nameEn: "Mahmoud Khalil Al-Husary",
                base: "https://server13.mp3quran.net/husr/Rewayat-Qalon-A-n-Nafi/", timingRead: 270),
        Reciter(id: "huthaifi", nameAr: "علي الحذيفي", nameEn: "Ali Al-Huthaifi",
                base: "https://server9.mp3quran.net/huthifi_qalon/", timingRead: 75),
        Reciter(id: "deban", nameAr: "أحمد دعبان", nameEn: "Ahmad Deban",
                base: "https://server16.mp3quran.net/deban/Rewayat-Qalon-A-n-Nafi/", timingRead: nil),
    ]
    static let defaultId = "husary"

    static func byId(_ id: String) -> Reciter {
        all.first { $0.id == id } ?? all[0]
    }
}

/// Start/end of one ayah in a surah file, in seconds.
struct AyahTiming: Hashable {
    let ayah: Int
    let start: Double
    let end: Double
}

/// Which ayah count the timing rows follow. Only `.madani` rows map 1:1 to our ayah ids.
enum AyahNumbering {
    case madani, hafs, unknown
}

struct SurahTimings {
    let surah: Int
    let read: Int
    let numbering: AyahNumbering
    let timings: [AyahTiming]
}

enum RecitationError: LocalizedError {
    case upstream
    case loadFailed
    case numbering(String)
    case missingTiming(Int, Int)

    var errorDescription: String? {
        switch self {
        case .upstream: return "تعذّر جلب توقيتات الآيات من الخادم."
        case .loadFailed: return "تعذّر تحميل التلاوة من الخادم."
        case .numbering(let reciter):
            return "توقيتات هذه السورة عند \(reciter) لا تتبع العدّ المدني؛ اختر قارئًا آخر."
        case .missingTiming(let s, let a):
            return "لا توجد توقيتات للآية \(s):\(a)."
        }
    }
}

/// MP3Quran ayah timings, cached in memory and in Caches/.
actor TimingService {
    static let shared = TimingService()

    private var memory: [String: SurahTimings] = [:]
    private let directory: URL

    init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        directory = base.appendingPathComponent("Mushaf/timings", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func timings(read: Int, surah: Int) async throws -> SurahTimings {
        let key = "\(read)-\(surah)"
        if let hit = memory[key] { return hit }
        let file = directory.appendingPathComponent("\(key).json")
        var raw = try? Data(contentsOf: file)
        if raw == nil {
            let url = URL(string: "https://mp3quran.net/api/v3/ayat_timing?surah=\(surah)&read=\(read)")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw RecitationError.upstream
            }
            raw = data
            try? data.write(to: file, options: .atomic)
        }
        let rows = Self.parse(raw ?? Data())
        let numbering: AyahNumbering = rows.isEmpty ? .unknown : Self.detectNumbering(surah: surah, rows: rows)
        let result = SurahTimings(surah: surah, read: read, numbering: numbering, timings: rows)
        memory[key] = result
        return result
    }

    /// Normalise MP3Quran's rows (`{ayah, start_time, end_time, …}`, milliseconds); drops the basmala row (ayah 0).
    static func parse(_ data: Data) -> [AyahTiming] {
        guard let any = try? JSONSerialization.jsonObject(with: data),
              let list = any as? [[String: Any]] else { return [] }
        var out: [AyahTiming] = []
        for item in list {
            guard let ayah = number(item["ayah"]),
                  let start = number(item["start_time"]),
                  let end = number(item["end_time"]) else { continue }
            let n = Int(ayah)
            guard Double(n) == ayah, n > 0 else { continue }
            out.append(AyahTiming(ayah: n, start: start / 1000, end: end / 1000))
        }
        return out.sorted { $0.ayah < $1.ayah }
    }

    private static func number(_ value: Any?) -> Double? {
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String { return Double(s) }
        return nil
    }

    /// When the Madani and Hafs counts agree for the surah the numbering is the same either way.
    static func detectNumbering(surah: Int, rows: [AyahTiming]) -> AyahNumbering {
        let last = rows.map(\.ayah).max() ?? 0
        let madani = Quran.shared.surah(surah).ayahCount
        let hafs = Quran.hafsAyahCounts[max(0, min(surah - 1, Quran.hafsAyahCounts.count - 1))]
        if last == madani { return .madani }
        if last == hafs { return .hafs }
        return .unknown
    }
}
