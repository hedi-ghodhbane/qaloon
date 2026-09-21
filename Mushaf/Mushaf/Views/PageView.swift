import SwiftUI

/// One mushaf page: the image, fitted and centred, with the ayah overlay
/// (selection, recitation highlight, covers) and tap-to-ayah hit testing.
struct PageCell: View {
    let page: Int
    let hideMode: Bool
    /// Ayah ids the reader has uncovered (hide mode).
    let revealed: Set<Int>
    let selected: Int?
    let active: Int?
    /// Saved progress ayah (outlined in gold when it is on this page).
    let progress: Int?
    /// Leave the end-of-ayah signs ۝ visible while the text is hidden.
    let keepMarkers: Bool
    let onTap: (Int) -> Void

    @State private var image: CGImage?
    @State private var failed = false

    private var layout: PageLayout { LayoutStore.shared.layout(for: page) }

    private var hidden: Set<Int> {
        hideMode ? Set(layout.ayahs.map(\.id)).subtracting(revealed) : []
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
                PageOverlay(layout: layout, hidden: hidden, selected: selected, active: active,
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
                if let hit = layout.ayah(at: point, padding: CGSize(width: 4, height: 10)) {
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
    let hidden: Set<Int>
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
            // Generous enough vertically to swallow diacritics that poke out of the line box.
            let padX: CGFloat = 4
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
            // Ayah signs to leave uncovered (all of them, so a neighbour's cover never clips one).
            let markers: [CGRect] = keepMarkers
                ? layout.ayahs.compactMap { $0.marker.map { display($0, padX: 3, padY: 6) } }
                : []
            // Hidden x-spans per line (image pixels), for one continuous rule per line.
            var hiddenSpans: [Int: [ClosedRange<CGFloat>]] = [:]

            for a in layout.ayahs {
                let isHidden = hidden.contains(a.id)
                let isProgress = a.id == progress
                let tint: Color? = a.id == active ? Theme.playing : (a.id == selected ? Theme.selected : nil)
                guard isHidden || isProgress || tint != nil else { continue }
                for s in a.segments {
                    let r = display(band(s), padX: padX, padY: padY)
                    if let tint {
                        context.fill(Path(roundedRect: display(band(s), padX: padX, padY: 6), cornerRadius: 6 * scale),
                                     with: .color(tint))
                    }
                    if isHidden {
                        // The page PNGs are transparent: the "paper" is the cell background, so a
                        // cover in the same colour is invisible. Holes keep the ayah signs visible.
                        // Only the part of a sign inside this cover is cut out: with even-odd
                        // filling, any hole area outside the cover would be painted instead.
                        var cover = Path(r)
                        let holes = markers.filter { $0.intersects(r) }
                        for hole in holes { cover.addRect(hole.intersection(r)) }
                        context.fill(cover, with: .color(Theme.parchment), style: FillStyle(eoFill: !holes.isEmpty))
                        hiddenSpans[s.line, default: []].append(s.rect.minX...s.rect.maxX)
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
