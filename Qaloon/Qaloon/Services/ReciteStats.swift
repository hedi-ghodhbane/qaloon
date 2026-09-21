import Foundation
import Observation

/// What the reader has recited aloud, day by day. Only words followed by ear count — a cover
/// lifted by hand was not recited. Kept in Application Support (`Mushaf/recited.json`).
@MainActor
@Observable
final class ReciteStats {
    static let shared = ReciteStats()

    struct Day: Codable, Equatable {
        var words = 0
        /// Written letters of those words (marks are not letters).
        var letters = 0
        /// Pages, in fractions: each word is its share of its page.
        var pages = 0.0
        /// Seconds of voice.
        var seconds = 0.0

        /// «من قرأ حرفًا من كتاب الله فله به حسنة، والحسنة بعشر أمثالها» (الترمذي).
        var hasanat: Int { letters * 10 }

        static func + (a: Day, b: Day) -> Day {
            Day(words: a.words + b.words, letters: a.letters + b.letters,
                pages: a.pages + b.pages, seconds: a.seconds + b.seconds)
        }
    }

    /// Keyed by local date, `yyyy-MM-dd`.
    private(set) var days: [String: Day] = [:]

    private let file: URL
    private var saving: Task<Void, Never>?

    private init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Mushaf", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        file = base.appendingPathComponent("recited.json")
        if let data = try? Data(contentsOf: file), let saved = try? JSONDecoder().decode([String: Day].self, from: data) {
            days = saved
        }
    }

    // MARK: - Recording

    /// Words just recited, as the mushaf spells them; `pageWords` is how many their page holds.
    func record(words: [String], pageWords: Int) {
        guard !words.isEmpty else { return }
        var day = days[Self.key(Date()), default: Day()]
        day.words += words.count
        day.letters += words.reduce(0) { $0 + Self.letters(in: $1) }
        day.pages += Double(words.count) / Double(max(1, pageWords))
        days[Self.key(Date())] = day
        save()
    }

    func record(seconds: Double) {
        days[Self.key(Date()), default: Day()].seconds += seconds
        save()
    }

    /// Written letters: Arabic letters proper. Harakat, the dagger alef, the small waw and ya,
    /// tatweel and the annotation signs are not letters.
    static func letters(in word: String) -> Int {
        word.unicodeScalars.reduce(0) { $0 + ($1.properties.generalCategory == .otherLetter ? 1 : 0) }
    }

    // MARK: - Reading

    var today: Day { days[Self.key(Date())] ?? Day() }
    var total: Day { days.values.reduce(Day(), +) }

    func day(_ date: Date) -> Day { days[Self.key(date)] ?? Day() }

    /// Consecutive days with recitation, ending today. A day still in progress does not break
    /// it: with nothing recited yet today, it is counted up to yesterday.
    var streak: Int {
        let calendar = Calendar.current
        var date = Date()
        if day(date).words == 0 { date = calendar.date(byAdding: .day, value: -1, to: date) ?? date }
        var n = 0
        while day(date).words > 0 {
            n += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return n
    }

    /// The last `weeks` weeks as columns, oldest first, Monday at the top; nil for days yet to come.
    func weeks(_ weeks: Int) -> [[Date?]] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = calendar.startOfDay(for: Date())
        guard let thisWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        return (0..<weeks).reversed().map { back in
            (0..<7).map { row in
                guard let date = calendar.date(byAdding: .day, value: row - back * 7, to: thisWeek) else { return nil }
                return date > today ? nil : date
            }
        }
    }

    /// 0…4: a day's words relative to the busiest day in view.
    static func level(_ words: Int, max: Int) -> Int {
        guard words > 0, max > 0 else { return 0 }
        return min(4, Swift.max(1, Int((Double(words) / Double(max) * 4).rounded(.up))))
    }

    // MARK: - Storage

    private static let keys: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func key(_ date: Date) -> String { keys.string(from: date) }

    /// Words arrive twice a second: write at most every few seconds.
    private func save() {
        guard saving == nil else { return }
        saving = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard let self else { return }
            self.saving = nil
            if let data = try? JSONEncoder().encode(self.days) { try? data.write(to: self.file, options: .atomic) }
        }
    }

    /// Writes now: the app is leaving the foreground.
    func flush() {
        saving?.cancel()
        saving = nil
        if let data = try? JSONEncoder().encode(days) { try? data.write(to: file, options: .atomic) }
    }
}
