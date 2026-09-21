import SwiftUI

/// What the reader has recited aloud: today, the streak, the totals, and a day grid like a
/// contribution graph — a column per week, the darker the more words that day.
struct StatsView: View {
    @State private var picked: Date?

    private var stats: ReciteStats { ReciteStats.shared }
    private static let weeksShown = 26

    var body: some View {
        Form {
            Section("اليوم") {
                numbers(stats.today)
                LabeledContent("أيام متتالية", value: Quran.arabicDigits(stats.streak))
            }
            Section("آخر ستة أشهر") {
                grid
                if let picked {
                    Text(Self.dayTitle.string(from: picked)).font(.footnote).foregroundStyle(.secondary)
                    numbers(stats.day(picked))
                } else {
                    Text("المسْ يومًا لترى ما تلوته فيه.").font(.footnote).foregroundStyle(.secondary)
                }
            }
            Section("المجموع") {
                numbers(stats.total)
            }
            Section {
                Text("يُحسب ما تتلوه بصوتك مع زرّ «سمِّع» فقط. الحسنات: عشر عن كل حرف مكتوب، لحديث «من قرأ حرفًا من كتاب الله فله به حسنة، والحسنة بعشر أمثالها»، والله يضاعف لمن يشاء. الإحصاءات محفوظة على هذا الجهاز.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("تلاوتي")
    }

    @ViewBuilder
    private func numbers(_ day: ReciteStats.Day) -> some View {
        LabeledContent("الكلمات", value: Quran.arabicDigits(day.words))
        LabeledContent("الصفحات", value: Self.pages(day.pages))
        LabeledContent("الحروف", value: Quran.arabicDigits(day.letters))
        LabeledContent("الحسنات", value: Quran.arabicDigits(day.hasanat))
        LabeledContent("مدة التلاوة", value: Self.duration(day.seconds))
    }

    /// Oldest week first: in this right-to-left app that puts today at the left end, where the
    /// eye finishes. Opens scrolled to today.
    private var grid: some View {
        let weeks = stats.weeks(Self.weeksShown)
        let busiest = weeks.joined().compactMap { $0 }.map { stats.day($0).words }.max() ?? 0
        return ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 3) {
                ForEach(weeks.indices, id: \.self) { w in
                    VStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { d in
                            if let date = weeks[w][d] {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Theme.heat[ReciteStats.level(stats.day(date).words, max: busiest)])
                                    .overlay {
                                        if picked == date {
                                            RoundedRectangle(cornerRadius: 3).stroke(Theme.gold, lineWidth: 2)
                                        }
                                    }
                                    .frame(width: 14, height: 14)
                                    .onTapGesture { picked = picked == date ? nil : date }
                                    .accessibilityLabel("\(Self.dayTitle.string(from: date)): \(stats.day(date).words) كلمة")
                            } else {
                                Color.clear.frame(width: 14, height: 14)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.trailing)
    }

    private static func pages(_ value: Double) -> String {
        let text = value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
        return Quran.arabicDigits(text.replacingOccurrences(of: ".", with: "٫"))
    }

    private static func duration(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 1 { return seconds > 0 ? "أقل من دقيقة" : "—" }
        let h = minutes / 60, m = minutes % 60
        return h > 0 ? "\(Quran.arabicDigits(h)) س \(Quran.arabicDigits(m)) د" : "\(Quran.arabicDigits(m)) د"
    }

    private static let dayTitle: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar")
        f.dateStyle = .full
        return f
    }()
}
