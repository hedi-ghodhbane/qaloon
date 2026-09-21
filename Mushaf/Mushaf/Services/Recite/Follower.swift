import Foundation

/// Follows a recitation through a known text. It is fed, a couple of times a second, the
/// recogniser's reading of the last few seconds of sound, and moves a cursor over the words
/// the reader is expected to say. The text being known is what makes this work: the
/// recogniser only has to tell the next word from its neighbours, not to be right.
struct Follower {
    /// Expected words searched behind and ahead of the cursor.
    static let back = 6, ahead = 14
    /// Skeleton similarity that counts as the same word.
    static let same = 0.72
    /// Taken off a match per word beyond the cursor: the same phrase often returns a few
    /// words later (67:16 / 67:17), and the reader is at the nearer one.
    static let far = 0.15

    private let expected: [String]
    /// Index of the next word not yet recited.
    private(set) var cursor = 0

    init(words: [String]) {
        expected = words.map(Skeleton.of)
    }

    var isDone: Bool { cursor >= expected.count }

    /// The skeletons of a hypothesis' words.
    static func words(of hypothesis: String) -> [String] {
        hypothesis.split(whereSeparator: \.isWhitespace).map { Skeleton.of(String($0)) }.filter { !$0.isEmpty }
    }

    /// Takes a hypothesis; returns the indices it newly covers (empty when it moves nothing).
    /// `final` says the sound ended in a pause, so the last word heard is a whole word.
    ///
    /// The cursor only ever moves over words that were heard, one after the other: a reader
    /// who leaves a word out is stopped there, whatever they go on to say.
    mutating func feed(_ hypothesis: String, final: Bool) -> Range<Int> {
        var heard = Self.words(of: hypothesis)
        if !final, let last = heard.last {
            // The last word of a live hypothesis is usually cut short. It stays only when it
            // is already, letter for letter, a word the text expects next.
            let near = expected[min(cursor, expected.count)..<min(cursor + 3, expected.count)]
            if !(last.unicodeScalars.count >= 3 && near.contains(last)) { heard.removeLast() }
        }
        guard !heard.isEmpty, !isDone else { return cursor..<cursor }

        let lo = max(0, cursor - Self.back), hi = min(expected.count, cursor + Self.ahead)
        let text = Array(expected[lo..<hi])
        let n = heard.count, m = text.count

        // Local alignment of what was heard against the text: matches score, gaps cost.
        enum Step { case none, match, heardOnly, textOnly }
        var score = [[Double]](repeating: [Double](repeating: 0, count: m + 1), count: n + 1)
        var step = [[Step]](repeating: [Step](repeating: .none, count: m + 1), count: n + 1)
        var alike = [[Bool]](repeating: [Bool](repeating: false, count: m + 1), count: n + 1)
        var best = 0.0, at: (Int, Int)?
        for i in 1...n {
            for j in 1...m {
                let s = Skeleton.similarity(heard[i - 1], text[j - 1])
                let beyond = Self.far * Double(max(0, lo + j - 1 - cursor))
                alike[i][j] = s >= Self.same
                let d = score[i - 1][j - 1] + (alike[i][j] ? 2 * s - beyond : -1)
                let u = score[i - 1][j] - 0.7        // a heard word that is not in the text
                let l = score[i][j - 1] - 0.7        // a text word that was not heard
                var v = d, p = Step.match
                if u > v { v = u; p = .heardOnly }
                if l > v { v = l; p = .textOnly }
                if v < 0 { v = 0; p = .none }
                score[i][j] = v
                step[i][j] = p
                if v > best { best = v; at = (i, j) }
            }
        }
        guard var (i, j) = at else { return cursor..<cursor }
        var hits: [Int] = []
        while i > 0, j > 0, step[i][j] != .none {
            switch step[i][j] {
            case .match:
                if alike[i][j] { hits.append(lo + j - 1) }
                i -= 1; j -= 1
            case .heardOnly: i -= 1
            case .textOnly: j -= 1
            case .none: break
            }
        }
        hits.reverse()

        // The recitation continues from the cursor, so the matches must too: walk them in
        // order and stop at the first that would leap over a word that was not heard.
        var reach = cursor, fresh = 0
        for h in hits where h >= reach {
            if h != reach { break }
            reach = h + 1
            fresh += 1
        }
        guard fresh > 0 else { return cursor..<cursor }
        // One new word needs support: an earlier match in the same hypothesis, or a long word.
        let anchored = hits.contains { $0 < cursor } || fresh >= 2
        if !anchored, expected[reach - 1].unicodeScalars.count < 4 { return cursor..<cursor }
        let moved = cursor..<reach
        cursor = reach
        return moved
    }

    /// Puts the cursor on a word: the reader tapped ahead, or covered part of the page again.
    mutating func move(to index: Int) {
        cursor = max(0, min(index, expected.count))
    }
}
