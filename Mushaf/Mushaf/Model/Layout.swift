import Foundation
import CoreGraphics

/// One line-segment of an ayah on a page, in page-image pixels (1310 × 2032).
struct Segment: Hashable {
    let line: Int
    let rect: CGRect
}

struct LayoutAyah: Identifiable, Hashable {
    let id: Int
    let surah: Int
    let ayah: Int
    /// Segments on THIS page, in reading order.
    let segments: [Segment]
    /// Box of the end-of-ayah sign ۝ when it is on this page.
    let marker: CGRect?
}

struct PageLayout {
    let page: Int
    /// Ayahs with any text on the page, in reading order.
    let ayahs: [LayoutAyah]

    /// The ayah whose (padded) box contains `point`, in image pixels.
    func ayah(at point: CGPoint, padding: CGSize) -> LayoutAyah? {
        ayahs.first { a in
            a.segments.contains { s in
                s.rect.insetBy(dx: -padding.width, dy: -padding.height).contains(point)
            }
        }
    }
}

/// Ayah boxes for all 604 pages, from the bundled `layout.json`
/// (`node scripts/build-native-data.mjs`).
final class LayoutStore {
    static let shared = LayoutStore()

    private let pages: [PageLayout]

    private struct File: Decodable {
        let pages: [[Row]]
    }

    /// `[ayahId, surah, ayah, [[line, x1, y1, x2, y2], …], [x1, y1, x2, y2] | null]`
    private struct Row: Decodable {
        let id: Int
        let surah: Int
        let ayah: Int
        let segments: [[Double]]
        let marker: [Double]?

        init(from decoder: Decoder) throws {
            var c = try decoder.unkeyedContainer()
            id = try c.decode(Int.self)
            surah = try c.decode(Int.self)
            ayah = try c.decode(Int.self)
            segments = try c.decode([[Double]].self)
            marker = c.isAtEnd ? nil : try c.decode([Double]?.self)
        }
    }

    private init() {
        guard let url = Bundle.main.url(forResource: "layout", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(File.self, from: data)
        else {
            fatalError("layout.json is missing from the app bundle")
        }
        pages = file.pages.enumerated().map { i, rows in
            PageLayout(page: i + 1, ayahs: rows.map { r in
                let marker: CGRect? = r.marker.flatMap { m in
                    m.count >= 4 ? CGRect(x: m[0], y: m[1], width: m[2] - m[0], height: m[3] - m[1]) : nil
                }
                return LayoutAyah(id: r.id, surah: r.surah, ayah: r.ayah, segments: r.segments.compactMap { v in
                    guard v.count >= 5 else { return nil }
                    return Segment(line: Int(v[0]),
                                   rect: CGRect(x: v[1], y: v[2], width: v[3] - v[1], height: v[4] - v[2]))
                }, marker: marker)
            })
        }
    }

    func layout(for page: Int) -> PageLayout {
        pages[max(1, min(page, pages.count)) - 1]
    }
}

extension LayoutStore: @unchecked Sendable {}
