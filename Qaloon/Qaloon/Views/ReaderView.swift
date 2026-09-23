import SwiftUI

/// The reader: pages side by side (swipe or arrow keys to turn; in an RTL
/// book the next page lies to the left), a caption, and a bottom bar with
/// hide/reveal, listen, navigate and tools.
struct ReaderView: View {
    @AppStorage("lastPage") private var savedPage = 1
    @AppStorage("reciter") private var reciterId = Reciters.defaultId
    @AppStorage("repeatCount") private var repeatCount = 1
    @AppStorage("autoAdvance") private var autoAdvance = true
    /// Remembered: someone memorising comes back to the covered page.
    @AppStorage("hideMode") private var hideMode = false
    /// The ayah the reader has reached (0 = none); drawn with a gold outline.
    @AppStorage("progressAyah") private var progressAyah = 0
    /// Hide mode leaves the end-of-ayah signs visible.
    @AppStorage("keepMarkers") private var keepMarkers = true
    /// Hide mode: a tap on the text lifts one word rather than the whole ayah. Both stay in
    /// reach either way: the bar lifts the next word or the next ayah, and the sign ۝ is its ayah.
    @AppStorage("tapRevealsWord") private var tapWord = true
    /// Hide mode leaves each ayah's opening word visible: the prompt to recite the rest from.
    @AppStorage("keepOpening") private var keepOpening = true

    @State private var page: Int?
    /// Covers are per word; an ayah is lifted by lifting its words.
    @State private var revealedWords: Set<Int> = []
    @State private var selectedAyah: Int?
    @State private var sheet: Sheet?
    @FocusState private var focused: Bool
    @Environment(\.scenePhase) private var scenePhase

    private let quran = Quran.shared
    private var player: AyahPlayer { AyahPlayer.shared }
    private var images: PageImageStore { PageImageStore.shared }
    private var recite: ReciteSession { ReciteSession.shared }

    enum Sheet: String, Identifiable {
        case navigate, tools
        var id: String { rawValue }
    }

    private struct AutoTurnKey: Hashable {
        let page: Int
        let hide: Bool
        let remaining: Int
        let revealedCount: Int
        let enabled: Bool
    }

    private var current: Int { page ?? quran.clampPage(savedPage) }
    private var layout: PageLayout { LayoutStore.shared.layout(for: current) }
    /// Words still covered on this page, in reading order.
    private var coveredWords: [LayoutWord] {
        guard hideMode else { return [] }
        return layout.hideableWords(keepOpening: keepOpening).filter { !revealedWords.contains($0.key) }
    }
    private var remaining: Int { coveredWords.count }
    /// How many covers the reader has lifted (drives the auto page-turn).
    private var liftedCount: Int { revealedWords.count }
    private var reciter: Reciter { Reciters.byId(reciterId) }

    var body: some View {
        VStack(spacing: 0) {
            caption
            pager
            listeningLine
            bottomBar
        }
        .background(Theme.parchment.ignoresSafeArea())
        .sheet(item: $sheet) { which in
            switch which {
            case .navigate:
                NavigateSheet(page: current) { goTo($0) }
            case .tools:
                ToolsSheet(page: current, selectedAyah: selectedAyah, reciterId: $reciterId,
                           repeatCount: $repeatCount, autoAdvance: $autoAdvance, hideMode: $hideMode,
                           progressAyah: $progressAyah, keepMarkers: $keepMarkers,
                           tapWord: $tapWord, keepOpening: $keepOpening,
                           onHideAll: { hideAll() },
                           onGoTo: { goTo($0) })
            }
        }
        .onAppear {
            if page == nil { page = quran.clampPage(savedPage) }
            focused = true
            images.prefetch(around: current)
            SyncService.shared.start()
            if hideMode { recite.warmUp() }
        }
        .onChange(of: page) { _, newValue in
            guard let newValue else { return }
            savedPage = newValue
            hideAll()
            selectedAyah = nil
            images.prefetch(around: newValue)
        }
        // Changing what is hidden starts the page covered again.
        .onChange(of: keepOpening) { _, _ in hideAll() }
        // Reciting happens in hide mode: get the model ready as it goes on, let it go as it goes off.
        .onChange(of: hideMode) { _, on in
            if on { recite.warmUp() } else { recite.stop(); recite.release() }
        }
        // A page adopted from another device (sync writes `lastPage`) moves the reader.
        .onChange(of: savedPage) { _, newValue in
            let target = quran.clampPage(newValue)
            if page != target { page = target }
        }
        // Coming back to the app is when the other device's progress matters.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await SyncService.shared.syncNow() } } else { recite.stop() }
        }
        // Hide mode: once every cover on the page is lifted, continue on the
        // next page (hidden again) after a short pause. Any change cancels.
        .task(id: AutoTurnKey(page: current, hide: hideMode, remaining: remaining,
                              revealedCount: liftedCount, enabled: autoAdvance)) {
            guard autoAdvance, hideMode, remaining == 0, liftedCount > 0,
                  current < quran.pageCount else { return }
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            turn(1)
        }
        // A word left out: the reader feels it, not only sees the red outline.
        .sensoryFeedback(.error, trigger: recite.stoppedAt) { _, now in now != nil }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) { turn(1); return .handled }
        .onKeyPress(.rightArrow) { turn(-1); return .handled }
        // Hide mode: space lifts the next word, return the next ayah.
        .onKeyPress(.space) {
            if hideMode { revealNextWord() } else { togglePlay() }
            return .handled
        }
        .onKeyPress(.return) {
            guard hideMode else { return .ignored }
            revealNextAyah()
            return .handled
        }
    }

    // MARK: - Pieces

    private var caption: some View {
        let info = quran.page(current)
        let firstSurah = layout.ayahs.first.map { quran.surah($0.surah).nameAr } ?? ""
        var text = "\(firstSurah) · صفحة \(Quran.arabicDigits(current)) · الجزء \(Quran.arabicDigits(info.juz)) · الحزب \(Quran.arabicDigits(info.hizb))"
        if let id = selectedAyah { text += " · \(quran.label(ayahId: id))" }
        return HStack(spacing: 8) {
            Button { turn(-1) } label: { Image(systemName: "chevron.backward") }
                .disabled(current <= 1)
                .accessibilityLabel("الصفحة السابقة")
            Spacer(minLength: 0)
            Text(text)
                .font(.footnote)
                .foregroundStyle(Theme.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            Button { turn(1) } label: { Image(systemName: "chevron.forward") }
                .disabled(current >= quran.pageCount)
                .accessibilityLabel("الصفحة التالية")
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.green)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var pager: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(1...quran.pageCount, id: \.self) { p in
                    PageCell(page: p,
                             hideMode: hideMode,
                             selected: p == current ? selectedAyah : nil,
                             active: player.activeAyah,
                             progress: progressAyah > 0 ? progressAyah : nil,
                             keepMarkers: keepMarkers,
                             tapWord: tapWord,
                             keepOpening: keepOpening,
                             revealedWords: p == current ? revealedWords : [],
                             stopped: p == current ? recite.stoppedAt?.key : nil,
                             onTap: { id in tap(id) },
                             onTapWord: { word in tap(word) })
                        .containerRelativeFrame(.horizontal)
                        .id(p)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $page)
        .scrollIndicators(.hidden)
    }

    /// While listening: what was last heard, so the reader can tell they are being followed.
    @ViewBuilder
    private var listeningLine: some View {
        if case .failed(let message) = recite.status {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        } else if recite.isOn {
            HStack(spacing: 6) {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative, isActive: recite.status == .listening)
                Text(recite.status == .loading
                     ? (recite.preparing > 3
                        ? "جارٍ تجهيز الاستماع… \(Quran.arabicDigits(Int(recite.preparing))) ث (المرة الأولى بعد التثبيت أطول)"
                        : "جارٍ تجهيز الاستماع…")
                     : (recite.heard.isEmpty ? "اقرأ…" : recite.heard))
                    .lineLimit(1)
                    .truncationMode(.head)
                if recite.passSeconds > 0 {
                    Spacer(minLength: 4)
                    // The model's pass time, so a slow device shows for what it is.
                    Text(Quran.arabicDigits(String(format: "%.1f", recite.passSeconds)).replacingOccurrences(of: ".", with: "٫") + " ث")
                        .monospacedDigit()
                        .foregroundStyle(recite.passSeconds > 0.6 ? Theme.stopped : Theme.inkSoft)
                }
            }
            .font(.footnote)
            .foregroundStyle(Theme.inkSoft)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 4) {
            BarButton(title: hideMode ? "إظهار" : "إخفاء",
                      system: hideMode ? "eye" : "eye.slash",
                      active: hideMode) {
                hideMode.toggle()
                hideAll()
            }
            if hideMode {
                let covered = coveredWords
                if covered.isEmpty {
                    BarButton(title: "الصفحة التالية", system: "arrow.forward.circle", active: false) { turn(1) }
                } else {
                    // Both steps side by side: the next word, or the rest of the next ayah.
                    BarButton(title: "كلمة (\(Quran.arabicDigits(covered.count)))",
                              system: "chevron.forward", active: false) { revealNextWord() }
                    BarButton(title: "آية (\(Quran.arabicDigits(Set(covered.map(\.ayahId)).count)))",
                              system: "chevron.forward.2", active: false) { revealNextAyah() }
                }
                // Recite aloud and the words appear as they are said.
                if ReciteSession.isAvailable {
                    BarButton(title: recite.status == .loading ? "تحميل…" : "سمِّع",
                              system: recite.isOn ? "mic.fill" : "mic", active: recite.isOn) { toggleRecite() }
                }
            }
            BarButton(title: player.isBusy ? "إيقاف" : (selectedAyah != nil ? "الآية" : "استمع"),
                      system: player.isBusy ? "stop.fill" : "play.fill",
                      active: player.isBusy) { togglePlay() }
            // Progress: with an ayah selected, save it; otherwise jump back to it. Not while
            // hiding: the bar is full there, and the tools sheet has both.
            if !hideMode, let id = selectedAyah, id != progressAyah {
                BarButton(title: "احفظ", system: "bookmark", active: false) {
                    progressAyah = id
                    selectedAyah = nil
                }
            } else if !hideMode, progressAyah > 0 {
                BarButton(title: "موضعي", system: "bookmark.fill", active: false) {
                    goTo(quran.ayah(progressAyah).pageStart)
                }
            }
            Spacer(minLength: 0)
            BarButton(title: "انتقال", system: "list.bullet", active: false) { sheet = .navigate }
            BarButton(title: "الأدوات", system: "ellipsis.circle", active: false) { sheet = .tools }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.parchment)
        .overlay(alignment: .top) { Theme.line.frame(height: 1) }
    }

    // MARK: - Actions

    private func turn(_ delta: Int) {
        let next = current + delta
        guard next >= 1, next <= quran.pageCount else { return }
        withAnimation(.easeInOut(duration: 0.25)) { page = next }
    }

    private func goTo(_ p: Int) {
        sheet = nil
        page = quran.clampPage(p)
    }

    /// A tapped ayah: selects it when reading. In hide mode lifts all of its covers, or puts
    /// them all back when none is left.
    private func tap(_ id: Int) {
        guard hideMode else {
            selectedAyah = selectedAyah == id ? nil : id
            return
        }
        let keys = wordKeys(ofAyah: id)
        if keys.allSatisfy(revealedWords.contains) {
            revealedWords.subtract(keys)
        } else {
            revealedWords.formUnion(keys)
            skipRecitation(pastAyah: id)
        }
    }

    /// A tapped word: lift its cover, or put it back. The star and a kept opening word have none.
    private func tap(_ word: LayoutWord) {
        guard word.isHideable(keepOpening: keepOpening) else { return }
        if revealedWords.contains(word.key) {
            revealedWords.remove(word.key)
        } else {
            revealedWords.insert(word.key)
            recite.skip(past: word)
        }
    }

    /// Keys of the words of an ayah that hide mode covers on this page.
    private func wordKeys(ofAyah id: Int) -> [Int] {
        layout.ayahs.first { $0.id == id }?.words
            .filter { $0.isHideable(keepOpening: keepOpening) }
            .map(\.key) ?? []
    }

    private func hideAll() {
        revealedWords = []
        if recite.isOn { recite.follow(layout) }
    }

    private func revealNextWord() {
        guard let next = coveredWords.first else { return turn(1) }
        revealedWords.insert(next.key)
        recite.skip(past: next)
    }

    /// Lifts what is left of the first ayah that still has a covered word.
    private func revealNextAyah() {
        guard let next = coveredWords.first else { return turn(1) }
        revealedWords.formUnion(wordKeys(ofAyah: next.ayahId))
        skipRecitation(pastAyah: next.ayahId)
    }

    /// An ayah lifted by hand: the listener goes on from its last word on this page.
    private func skipRecitation(pastAyah id: Int) {
        if let last = layout.ayahs.first(where: { $0.id == id })?.words.last { recite.skip(past: last) }
    }

    /// Starts or stops listening. Each word heard loses its cover; the page turn follows by itself.
    private func toggleRecite() {
        if recite.isOn {
            recite.stop()
        } else {
            recite.start(page: layout, handlers: .init(
                lift: { words in revealedWords.formUnion(words.map(\.key)) },
                pageEnd: {
                    // Begun mid-page by hand, the top of it may still be covered and the page
                    // would not turn by itself; the recitation has reached its end all the same.
                    guard autoAdvance, remaining > 0, current < quran.pageCount else { return }
                    let from = current
                    Task {
                        try? await Task.sleep(for: .milliseconds(900))
                        if current == from, recite.isOn { turn(1) }
                    }
                },
                // The reader began a surah that is not on screen: go to it, covered.
                go: { target in withAnimation(.easeInOut(duration: 0.25)) { page = quran.clampPage(target) } }
            ))
        }
    }

    private func togglePlay() {
        if player.isBusy {
            player.stop()
            return
        }
        if let id = selectedAyah {
            player.play(from: id, to: id, times: repeatCount, reciter: reciter)
        } else {
            let info = quran.page(current)
            player.play(from: info.firstAyahId, to: info.lastAyahId, times: repeatCount, reciter: reciter)
        }
    }
}

/// Icon over a short label, for the bottom bar.
struct BarButton: View {
    let title: String
    let system: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: system)
                    .font(.system(size: 18, weight: .medium))
                Text(title)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(minWidth: 50)
            .padding(.vertical, 6)
            .padding(.horizontal, 3)
            .foregroundStyle(active ? Theme.parchment : Theme.green)
            .background(active ? Theme.green : Color.clear, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
