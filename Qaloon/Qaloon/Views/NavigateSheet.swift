import SwiftUI

/// Jump to a page, a juz or a surah.
struct NavigateSheet: View {
    let page: Int
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var pageText = ""

    private let quran = Quran.shared

    private var parsedPage: Int? {
        // Accept Arabic-Indic digits too.
        let ascii = pageText.compactMap { $0.wholeNumberValue.map(String.init) }.joined()
        guard let n = Int(ascii), n >= 1, n <= quran.pageCount else { return nil }
        return n
    }

    var body: some View {
        NavigationStack {
            List {
                Section("صفحة") {
                    HStack {
                        TextField("رقم الصفحة (١ – \(Quran.arabicDigits(quran.pageCount)))", text: $pageText)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .onSubmit { if let p = parsedPage { onSelect(p) } }
                        Button("اذهب") { if let p = parsedPage { onSelect(p) } }
                            .disabled(parsedPage == nil)
                    }
                    Text("أنت الآن في الصفحة \(Quran.arabicDigits(page))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("الأجزاء") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                        ForEach(1...30, id: \.self) { juz in
                            Button {
                                onSelect(quran.juzStartPage(juz))
                            } label: {
                                Text(Quran.arabicDigits(juz))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.bordered)
                            .tint(quran.page(page).juz == juz ? Theme.gold : Theme.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("السور") {
                    ForEach(quran.surahs) { s in
                        Button {
                            onSelect(quran.surahStartPage(s.id))
                        } label: {
                            HStack {
                                Text("\(Quran.arabicDigits(s.id)) · \(s.nameAr)")
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text("صفحة \(Quran.arabicDigits(quran.surahStartPage(s.id)))")
                                    .foregroundStyle(.secondary)
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
            .navigationTitle("الانتقال")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 560)
        #endif
    }
}
