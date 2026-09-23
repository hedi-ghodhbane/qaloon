import Foundation

/// Finds where in the mushaf a reader is from the last few words they said: how «سمِّع» goes
/// to a surah nobody navigated to, and how it takes up a reader who starts mid-page.
///
/// The whole mushaf is one sequence of word skeletons (604 pages, basmalas included). A place
/// is accepted when the words heard — several in a row, ending where the sound ends — are
/// found there and nowhere else. «يا أيها الذين آمنوا» is in eighty-nine places: the locator
/// says nothing until the reader has said enough to tell them apart.
struct Locator {
    struct Place: Equatable {
        let page: Int
        /// Position in the page's recitation of the first word NOT yet said.
        let index: Int
        /// How many words, up to `index`, were heard.
        let run: Int
    }

    /// Words in a row that make a place, and how alike each must be.
    static let need = 4, sure = 0.8
    /// «أعوذ بالله من الشيطان الرجيم»: said before reciting, and found once in the text
    /// (16:98) — a reader beginning is not there. Its words are left out of the search.
    private static let istiadha = "أعوذ بالله من الشيطان الرجيم".split(separator: " ").map { Skeleton.of(String($0)) }

    private let words: [String]
    /// Global index of each page's first word (and, last, the total).
    private let starts: [Int]
    private let places: [String: [Int32]]

    /// `pages[p - 1]` is the recitation of page `p`, as spelled in the mushaf.
    init(pages: [[String]]) {
        var words: [String] = [], starts: [Int] = [], places: [String: [Int32]] = [:]
        words.reserveCapacity(80_000)
        for page in pages {
            starts.append(words.count)
            for text in page {
                let s = Skeleton.of(text)
                places[s, default: []].append(Int32(words.count))
                words.append(s)
            }
        }
        starts.append(words.count)
        self.words = words
        self.starts = starts
        self.places = places
    }

    /// `heard` less any three or more of the istiʿādha's words said in a row.
    static func withoutIstiadha(_ heard: [String]) -> [String] {
        var out: [String] = []
        var i = 0
        while i < heard.count {
            var k = 0
            while i + k < heard.count, k < istiadha.count,
                  Skeleton.similarity(heard[i + k], istiadha[k]) >= sure { k += 1 }
            if k >= 3 { i += k } else { out.append(heard[i]); i += 1 }
        }
        return out
    }

    /// The mushaf-wide index of a position in a page's recitation.
    func position(page: Int, index: Int) -> Int {
        starts[max(1, min(page, starts.count - 1)) - 1] + index
    }

    /// Where the reader is, or nil while it cannot be told. `heard` are skeletons, whole words only.
    func locate(_ heard: [String]) -> Place? {
        let tail = Array(Self.withoutIstiadha(heard).suffix(8))
        guard tail.count >= Self.need else { return nil }
        // Longest run first: it is the one that tells repeated phrases apart.
        for from in 0...(tail.count - Self.need) {
            var found: [Int] = []
            for g in places[tail[from]] ?? [] {
                var k = 1
                while from + k < tail.count, Int(g) + k < words.count,
                      Skeleton.similarity(tail[from + k], words[Int(g) + k]) >= Self.sure { k += 1 }
                if from + k == tail.count { found.append(Int(g) + k) }
            }
            guard let end = found.first else { continue }
            guard found.count == 1 else { return nil }       // said in several places: wait
            // The page of the last word heard; `end` may be that page's very end.
            let page = (starts.lastIndex { $0 < end } ?? 0) + 1
            return Place(page: page, index: end - starts[page - 1], run: tail.count - from)
        }
        return nil
    }
}
