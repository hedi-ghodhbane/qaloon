import Foundation
import CoreGraphics

/// One line-segment of an ayah on a page, in page-image pixels (1310 × 2032).
struct Segment: Hashable {
    let line: Int
    let rect: CGRect
}

/// One word of an ayah on a page. Boxes tile the line: neighbours share an edge.
struct LayoutWord: Hashable {
    enum Kind: Int {
        case word = 0
        /// The rub' al-hizb star ۞: a word row, but nothing to recite — never covered.
        case star = 1
        /// The ayah's opening word: the prompt word-hiding can leave visible.
        case opening = 2
    }

    let ayahId: Int
    /// 1-based position inside the ayah.
    let index: Int
    let line: Int
    let rect: CGRect
    let kind: Kind
    /// The word as the mushaf spells it: what a recitation is matched against.
    let text: String

    /// Stable key for "this word has been uncovered" (an ayah has at most 130 words).
    var key: Int { ayahId * 1000 + index }

    /// Whether hide mode covers this word: never the star, and not the opening word when it is the prompt.
    func isHideable(keepOpening: Bool) -> Bool {
        kind == .word || (kind == .opening && !keepOpening)
    }
}

struct LayoutAyah: Identifiable, Hashable {
    let id: Int
    let surah: Int
    let ayah: Int
    /// Segments on THIS page, in reading order.
    let segments: [Segment]
    /// Box of the end-of-ayah sign ۝ when it is on this page.
    let marker: CGRect?
    /// Words on THIS page, in order.
    let words: [LayoutWord]
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

    /// Every word on the page in reading order: down the lines, right to left along each.
    var words: [LayoutWord] {
        ayahs.flatMap(\.words).sorted {
            $0.line != $1.line ? $0.line < $1.line : $0.rect.maxX > $1.rect.maxX
        }
    }

    /// Words that hide mode covers, in reading order.
    func hideableWords(keepOpening: Bool) -> [LayoutWord] {
        words.filter { $0.isHideable(keepOpening: keepOpening) }
    }

    /// What a reader says on this page, in order: every word but the star, and the basmala
    /// ahead of a surah's first ayah (it has no word boxes, so no `word`).
    var recitation: [(text: String, word: LayoutWord?)] {
        ayahs.flatMap { a -> [(text: String, word: LayoutWord?)] in
            let said = a.words.filter { $0.kind != .star }.map { (text: $0.text, word: Optional($0)) }
            let opens = a.ayah == 1 && a.surah != 9 && a.words.first?.index == 1
            return (opens ? Self.basmala.map { (text: $0, word: nil) } : []) + said
        }
    }

    private static let basmala = ["بسم", "الله", "الرحمن", "الرحيم"]

    /// The ayah whose end-of-ayah sign ۝ contains `point`: in hide mode the sign is the handle
    /// for the whole ayah, whatever a tap on its words does.
    func ayah(markerAt point: CGPoint, padding: CGFloat) -> LayoutAyah? {
        ayahs.first { $0.marker?.insetBy(dx: -padding, dy: -padding).contains(point) == true }
    }

    /// The word whose box contains `point` (padded vertically only: the boxes already tile the line).
    func word(at point: CGPoint, padY: CGFloat) -> LayoutWord? {
        ayahs.lazy.flatMap(\.words).first {
            $0.rect.insetBy(dx: 0, dy: -padY).contains(point)
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

    /// `[ayahId, surah, ayah, [[line, x1, y1, x2, y2], …], [x1, y1, x2, y2] | null, [[w, line, x1, y1, x2, y2, kind], …], [spelling, …]]`
    private struct Row: Decodable {
        let id: Int
        let surah: Int
        let ayah: Int
        let segments: [[Double]]
        let marker: [Double]?
        let words: [[Double]]
        /// Spellings, one per row of `words`.
        let texts: [String]

        init(from decoder: Decoder) throws {
            var c = try decoder.unkeyedContainer()
            id = try c.decode(Int.self)
            surah = try c.decode(Int.self)
            ayah = try c.decode(Int.self)
            segments = try c.decode([[Double]].self)
            marker = c.isAtEnd ? nil : try c.decode([Double]?.self)
            words = c.isAtEnd ? [] : try c.decode([[Double]].self)
            texts = c.isAtEnd ? [] : try c.decode([String].self)
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
                let words: [LayoutWord] = r.words.enumerated().compactMap { n, v in
                    guard v.count >= 7 else { return nil }
                    return LayoutWord(ayahId: r.id, index: Int(v[0]), line: Int(v[1]),
                                      rect: CGRect(x: v[2], y: v[3], width: v[4] - v[2], height: v[5] - v[3]),
                                      kind: LayoutWord.Kind(rawValue: Int(v[6])) ?? .word,
                                      text: n < r.texts.count ? r.texts[n] : "")
                }
                return LayoutAyah(id: r.id, surah: r.surah, ayah: r.ayah, segments: r.segments.compactMap { v in
                    guard v.count >= 5 else { return nil }
                    return Segment(line: Int(v[0]),
                                   rect: CGRect(x: v[1], y: v[2], width: v[3] - v[1], height: v[4] - v[2]))
                }, marker: marker, words: words)
            })
        }
    }

    func layout(for page: Int) -> PageLayout {
        pages[max(1, min(page, pages.count)) - 1]
    }
}

extension LayoutStore: @unchecked Sendable {}
