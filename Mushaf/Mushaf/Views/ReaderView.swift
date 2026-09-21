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

    @State private var page: Int?
    @State private var revealed: Set<Int> = []
    @State private var selectedAyah: Int?
    @State private var sheet: Sheet?
    @FocusState private var focused: Bool
    @Environment(\.scenePhase) private var scenePhase

    private let quran = Quran.shared
    private var player: AyahPlayer { AyahPlayer.shared }
    private var images: PageImageStore { PageImageStore.shared }

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
    private var remaining: Int {
        hideMode ? layout.ayahs.reduce(0) { $0 + (revealed.contains($1.id) ? 0 : 1) } : 0
    }
    private var reciter: Reciter { Reciters.byId(reciterId) }

    var body: some View {
        VStack(spacing: 0) {
            caption
            pager
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
                           onHideAll: { revealed = [] },
                           onGoTo: { goTo($0) })
            }
        }
        .onAppear {
            if page == nil { page = quran.clampPage(savedPage) }
            focused = true
            images.prefetch(around: current)
            SyncService.shared.start()
        }
        .onChange(of: page) { _, newValue in
            guard let newValue else { return }
            savedPage = newValue
            revealed = []
            selectedAyah = nil
            images.prefetch(around: newValue)
        }
        // A page adopted from another device (sync writes `lastPage`) moves the reader.
        .onChange(of: savedPage) { _, newValue in
            let target = quran.clampPage(newValue)
            if page != target { page = target }
        }
        // Coming back to the app is when the other device's progress matters.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await SyncService.shared.syncNow() } }
        }
        // Hide mode: once every cover on the page is lifted, continue on the
        // next page (hidden again) after a short pause. Any change cancels.
        .task(id: AutoTurnKey(page: current, hide: hideMode, remaining: remaining,
                              revealedCount: revealed.count, enabled: autoAdvance)) {
            guard autoAdvance, hideMode, remaining == 0, !revealed.isEmpty,
                  current < quran.pageCount else { return }
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            turn(1)
        }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) { turn(1); return .handled }
        .onKeyPress(.rightArrow) { turn(-1); return .handled }
        .onKeyPress(.space) {
            if hideMode { revealNext() } else { togglePlay() }
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
                             revealed: p == current ? revealed : [],
                             selected: p == current ? selectedAyah : nil,
                             active: player.activeAyah,
                             progress: progressAyah > 0 ? progressAyah : nil,
                             keepMarkers: keepMarkers,
                             onTap: { id in tap(id) })
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

    private var bottomBar: some View {
        HStack(spacing: 4) {
            BarButton(title: hideMode ? "إظهار" : "إخفاء",
                      system: hideMode ? "eye" : "eye.slash",
                      active: hideMode) {
                hideMode.toggle()
                revealed = []
            }
            if hideMode {
                BarButton(title: remaining > 0 ? "التالي (\(Quran.arabicDigits(remaining)))" : "الصفحة التالية",
                          system: "arrow.forward.circle", active: false) { revealNext() }
            }
            BarButton(title: player.isBusy ? "إيقاف" : (selectedAyah != nil ? "الآية" : "استمع"),
                      system: player.isBusy ? "stop.fill" : "play.fill",
                      active: player.isBusy) { togglePlay() }
            // Progress: with an ayah selected, save it; otherwise jump back to it.
            if let id = selectedAyah, id != progressAyah {
                BarButton(title: "احفظ", system: "bookmark", active: false) {
                    progressAyah = id
                    selectedAyah = nil
                }
            } else if progressAyah > 0 {
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

    private func tap(_ id: Int) {
        if hideMode {
            if revealed.contains(id) { revealed.remove(id) } else { revealed.insert(id) }
        } else {
            selectedAyah = selectedAyah == id ? nil : id
        }
    }

    private func revealNext() {
        if let next = layout.ayahs.first(where: { !revealed.contains($0.id) }) {
            revealed.insert(next.id)
        } else {
            turn(1)
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
