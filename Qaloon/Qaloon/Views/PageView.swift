import SwiftUI

/// One mushaf page: the image, fitted and centred, with the ayah overlay
/// (selection, recitation highlight, covers) and tap-to-ayah hit testing.
struct PageCell: View {
    let page: Int
    let hideMode: Bool
    let selected: Int?
    let active: Int?
    /// Saved progress ayah (outlined in gold when it is on this page).
    let progress: Int?
    /// Leave the end-of-ayah signs ۝ visible while the text is hidden.
    let keepMarkers: Bool
    /// Hide mode: a tap on the text lifts one word (true) or the whole ayah (false).
    /// A tap on the ayah sign ۝ always takes the whole ayah.
    var tapWord = true
    /// Hide mode leaves each ayah's opening word visible, as the prompt.
    var keepOpening = true
    /// Word keys the reader has uncovered (hide mode). Covers are per word; an ayah is
    /// uncovered by uncovering its words.
    var revealedWords: Set<Int> = []
    /// Key of the word a reciting reader is stopped at: its cover is outlined.
    var stopped: Int?
    let onTap: (Int) -> Void
    var onTapWord: (LayoutWord) -> Void = { _ in }

    @State private var image: CGImage?
    @State private var failed = false

    private var layout: PageLayout { LayoutStore.shared.layout(for: page) }

    private var hiddenWords: [LayoutWord] {
        guard hideMode else { return [] }
        return layout.hideableWords(keepOpening: keepOpening).filter { !revealedWords.contains($0.key) }
    }

    var body: some View {
        GeometryReader { geo in
            let frame = Self.fit(Quran.shared.imageSize, in: geo.size)
            let scale = frame.width / Quran.shared.imageSize.width
            ZStack(alignment: .topLeading) {
                Theme.parchment
                if let image {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.minX, y: frame.minY)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.parchmentDeep)
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.minX, y: frame.minY)
                    Group {
                        if failed {
                            VStack(spacing: 8) {
                                Text("تعذّر تحميل صفحة \(Quran.arabicDigits(page))")
                                Text("تحقّق من الاتصال ثم المسْ الصفحة لإعادة المحاولة")
                                    .font(.footnote)
                            }
                            .foregroundStyle(Theme.inkSoft)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                PageOverlay(layout: layout, hiddenWords: hiddenWords,
                            stopped: hiddenWords.first { $0.key == stopped },
                            selected: selected, active: active,
                            progress: progress, keepMarkers: keepMarkers,
                            scale: scale, origin: frame.origin)
                    .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(SpatialTapGesture().onEnded { value in
                if failed {
                    failed = false
                    Task { await load() }
                    return
                }
                guard scale > 0 else { return }
                let point = CGPoint(x: (value.location.x - frame.minX) / scale,
                                    y: (value.location.y - frame.minY) / scale)
                if hideMode, let signed = layout.ayah(markerAt: point, padding: 0) {
                    onTap(signed.id)
                } else if hideMode, tapWord {
                    // A word wins over the padding round a sign: a whole ayah lifted by mistake
                    // spoils the test, a word lifted by mistake barely does.
                    if let word = layout.word(at: point, padY: 10) {
                        onTapWord(word)
                    } else if let signed = layout.ayah(markerAt: point, padding: 6) {
                        onTap(signed.id)
                    }
                } else if let hit = layout.ayah(at: point, padding: CGSize(width: 4, height: 10)) {
                    onTap(hit.id)
                }
            })
        }
        // Image and overlay share one un-mirrored coordinate space.
        .environment(\.layoutDirection, .leftToRight)
        .task(id: page) { await load() }
    }

    private func load() async {
        let result = await PageImageStore.shared.image(for: page)
        image = result
        failed = result == nil
    }

    /// Aspect-fit `size` inside `container`, centred.
    static func fit(_ size: CGSize, in container: CGSize) -> CGRect {
        guard size.width > 0, size.height > 0, container.width > 0, container.height > 0 else {
            return .zero
        }
        let s = min(container.width / size.width, container.height / size.height)
        let w = size.width * s
        let h = size.height * s
        return CGRect(x: (container.width - w) / 2, y: (container.height - h) / 2, width: w, height: h)
    }
}

/// Highlights and covers drawn over the page image in one Canvas pass.
struct PageOverlay: View {
    let layout: PageLayout
    /// Words to cover (hide mode).
    var hiddenWords: [LayoutWord] = []
    /// The covered word a reciting reader is stopped at.
    var stopped: LayoutWord?
    let selected: Int?
    let active: Int?
    let progress: Int?
    let keepMarkers: Bool
    /// Display pixels per image pixel.
    let scale: CGFloat
    /// Top-left of the fitted image in the cell.
    let origin: CGPoint

    var body: some View {
        Canvas(rendersAsynchronously: false) { context, _ in
            // At the ends of a line, and above the first / below the last, past the boxes.
            let padX: CGFloat = 8
            let padY: CGFloat = 14
            func display(_ r: CGRect, padX: CGFloat = 0, padY: CGFloat = 0) -> CGRect {
                CGRect(x: origin.x + (r.minX - padX) * scale,
                       y: origin.y + (r.minY - padY) * scale,
                       width: (r.width + padX * 2) * scale,
                       height: (r.height + padY * 2) * scale)
            }
            // Line geometry from every segment on the page: one band per printed line, so
            // covers and rules sit at the same height whichever ayah the text belongs to.
            var lineBoxes: [Int: CGRect] = [:]
            for a in layout.ayahs {
                for s in a.segments {
                    lineBoxes[s.line] = lineBoxes[s.line].map { $0.union(s.rect) } ?? s.rect
                }
            }
            func band(_ s: Segment) -> CGRect {
                let box = lineBoxes[s.line] ?? s.rect
                return CGRect(x: s.rect.minX, y: box.minY, width: s.rect.width, height: box.height)
            }
            // The vertical reach of a line's covers: halfway to the lines above and below, so
            // that nothing shows between lines (a descender, a mark; on 961 of the 8215 line
            // pairs the pitch is wider than the boxes plus padding) — but not more than `reach`,
            // which keeps a surah heading, and the basmala under it, out of the covers.
            let reach: CGFloat = 40
            var top: [Int: CGFloat] = [:], bottom: [Int: CGFloat] = [:]
            let lines = lineBoxes.keys.sorted()
            for (i, line) in lines.enumerated() {
                let box = lineBoxes[line]!
                top[line] = i > 0 ? box.minY - min(reach, (box.minY - lineBoxes[lines[i - 1]]!.maxY) / 2 + 1) : box.minY - padY
                bottom[line] = i + 1 < lines.count ? box.maxY + min(reach, (lineBoxes[lines[i + 1]]!.minY - box.maxY) / 2 + 1) : box.maxY + padY
            }
            // Ayah signs to leave uncovered (all of them, so a neighbour's cover never clips one).
            // The sign is a medallion — a diamond with bulging sides — so the hole is the
            // ellipse in its box: it holds the whole medallion and none of the box's corners,
            // where the next word's first mark sits. The box from the vector page is a hair
            // smaller than the printed medallion (its pink tips stick out top and bottom),
            // hence the padding. Cut as a box, 1563 of the 6214 signs showed a sliver of a
            // neighbour; as an ellipse, 32.
            let markers: [CGRect] = keepMarkers
                ? layout.ayahs.compactMap { $0.marker.map { display($0, padX: 1, padY: 6) } }
                : []
            var holes = Path()
            for m in markers { holes.addEllipse(in: m) }
            var covering = context
            if !markers.isEmpty { covering.clip(to: holes, options: .inverse) }
            // Hidden x-spans per line (image pixels), for one continuous rule per line.
            var hiddenSpans: [Int: [ClosedRange<CGFloat>]] = [:]

            for a in layout.ayahs {
                let isProgress = a.id == progress
                let tint: Color? = a.id == active ? Theme.playing : (a.id == selected ? Theme.selected : nil)
                guard isProgress || tint != nil else { continue }
                for s in a.segments {
                    if let tint {
                        context.fill(Path(roundedRect: display(band(s), padX: padX, padY: 6), cornerRadius: 6 * scale),
                                     with: .color(tint))
                    }
                    if isProgress {
                        context.stroke(Path(roundedRect: display(band(s), padX: padX, padY: 6).insetBy(dx: 1, dy: 1),
                                            cornerRadius: 6 * scale),
                                       with: .color(Theme.gold), lineWidth: 2)
                    }
                }
                // Bookmark at the end of the progress ayah (its last segment ends at the left in RTL).
                if isProgress, let last = a.segments.last {
                    let r = display(last.rect)
                    let size = max(10, 14 * scale)
                    var mark = Path()
                    let x = r.minX - size * 0.9
                    let top = r.minY
                    mark.move(to: CGPoint(x: x, y: top))
                    mark.addLine(to: CGPoint(x: x + size * 0.7, y: top))
                    mark.addLine(to: CGPoint(x: x + size * 0.7, y: top + size * 1.3))
                    mark.addLine(to: CGPoint(x: x + size * 0.35, y: top + size))
                    mark.addLine(to: CGPoint(x: x, y: top + size * 1.3))
                    mark.closeSubpath()
                    context.fill(mark, with: .color(Theme.gold))
                }
            }

            // Everything that sits on a line, words and ayah signs, in order: a cover reaches
            // halfway to the neighbours of what it covers, so the line is tiled with no gap.
            // The word boxes already meet each other; between a word and a sign they stop at
            // the midpoint, and the sign's own box is narrower than that — the strip between,
            // covered by nothing, is where a tail showed beside every sign.
            var items: [Int: [CGRect]] = [:]
            for a in layout.ayahs {
                for w in a.words { items[w.line, default: []].append(w.rect) }
                if let m = a.marker, let line = lineBoxes.first(where: { $0.value.minY <= m.midY && m.midY <= $0.value.maxY })?.key {
                    items[line, default: []].append(m)
                }
            }
            for line in items.keys { items[line]!.sort { $0.minX < $1.minX } }

            // Covers, one per hidden word; a hidden ayah is simply all of its words. The page PNGs
            // are transparent: the "paper" is the cell background, so a cover in the same colour is
            // invisible. A cover takes the line's reach vertically, and, sideways, from midway to
            // the item before to midway to the item after (the ends of a line get padding). All
            // of them make ONE path, filled once: covers drawn one after the other leave a seam
            // where their antialiased edges overlap — an edge pixel half-covered twice is not
            // covered fully — and a letter stroke under the join shows as a tick. Drawn through
            // `covering`, clipped so the ayah signs stay visible.
            var covers = Path()
            func cover(_ rect: CGRect, line: Int) {
                let box = lineBoxes[line] ?? rect
                let row = items[line] ?? []
                let before = row.filter { $0.maxX <= rect.minX + 1 && $0 != rect }.max { $0.maxX < $1.maxX }
                let after = row.filter { $0.minX >= rect.maxX - 1 && $0 != rect }.min { $0.minX < $1.minX }
                let x0 = before.map { ($0.maxX + rect.minX) / 2 - 0.75 } ?? min(rect.minX, box.minX) - padX
                let x1 = after.map { ($0.minX + rect.maxX) / 2 + 0.75 } ?? max(rect.maxX, box.maxX) + padX
                let y0 = top[line] ?? box.minY - padY, y1 = bottom[line] ?? box.maxY + padY
                covers.addRect(display(CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0)))
                hiddenSpans[line, default: []].append(rect.minX...rect.maxX)
            }
            for w in hiddenWords { cover(w.rect, line: w.line) }
            // Where a reciting reader is stopped: the cover stays, and says "this one".
            if let w = stopped, let box = lineBoxes[w.line] {
                let r = display(CGRect(x: w.rect.minX, y: box.minY, width: w.rect.width, height: box.height), padY: 6)
                context.stroke(Path(roundedRect: r.insetBy(dx: 1, dy: 1), cornerRadius: 6 * scale),
                               with: .color(Theme.stopped), lineWidth: 2)
            }
            // With the signs hidden too, an ayah's sign goes while any of its words is covered.
            if !keepMarkers {
                let covered = Set(hiddenWords.map(\.ayahId))
                for a in layout.ayahs where covered.contains(a.id) {
                    guard let sign = a.marker,
                          let line = lineBoxes.first(where: { $0.value.minY <= sign.midY && sign.midY <= $0.value.maxY })?.key
                    else { continue }
                    cover(sign, line: line)
                }
            }
            covering.fill(covers, with: .color(Theme.parchment))

            // One faint dashed rule per line, a little under the line's text, spanning the
            // hidden ayahs on it (adjacent spans merge) and breaking around the ayah signs.
            var rule = Path()
            for (line, spans) in hiddenSpans {
                guard let box = lineBoxes[line] else { continue }
                let y = origin.y + (box.maxY + 6) * scale
                let signs = markers
                    .filter { $0.midY > origin.y + box.minY * scale && $0.midY < origin.y + box.maxY * scale }
                    .sorted { $0.minX < $1.minX }
                var merged: [ClosedRange<CGFloat>] = []
                for span in spans.sorted(by: { $0.lowerBound < $1.lowerBound }) {
                    if let last = merged.last, span.lowerBound <= last.upperBound + 12 {
                        merged[merged.count - 1] = last.lowerBound...max(last.upperBound, span.upperBound)
                    } else {
                        merged.append(span)
                    }
                }
                for span in merged {
                    var x0 = origin.x + span.lowerBound * scale
                    let x1 = origin.x + span.upperBound * scale
                    for sign in signs where sign.maxX > x0 && sign.minX < x1 {
                        if sign.minX - 2 > x0 {
                            rule.move(to: CGPoint(x: x0, y: y))
                            rule.addLine(to: CGPoint(x: sign.minX - 2, y: y))
                        }
                        x0 = max(x0, sign.maxX + 2)
                    }
                    if x1 > x0 {
                        rule.move(to: CGPoint(x: x0, y: y))
                        rule.addLine(to: CGPoint(x: x1, y: y))
                    }
                }
            }
            context.stroke(rule, with: .color(Theme.coverLine),
                           style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 5]))
        }
    }
}
