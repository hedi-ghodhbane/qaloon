import Foundation

/// One page being recited: the follower, plus the two things that are not its business —
/// finding a reader who is somewhere else before they have been taken up, and noticing a
/// reader who is stopped.
///
/// Until the first word is followed the reader may be anywhere: on this page further down, or
/// in another surah altogether, and the locator is asked. From then on they are held to the
/// text: a word left out stops them there, and nothing said after it is shown.
struct Tracker {
    enum Outcome: Equatable {
        case nothing
        /// These positions of the page's recitation were just recited.
        case recited(Range<Int>)
        /// The reader is elsewhere: on this page or another.
        case elsewhere(Locator.Place)
        /// The reader goes on speaking and nothing fits: they are stopped at this position.
        case stopped(at: Int)
    }

    /// Passes in a row in which the reader has said two or more words past the cursor that
    /// the text cannot take, before they count as stopped (3 s or so). Two, not one: the last
    /// word of a live transcript is dropped, and the model rewrites the end of what it hears
    /// as the sound goes on — a long madd is not a wrong word.
    static let patience = 6, unfitting = 2

    let page: Int
    /// Positions that say nothing about where a reader is: the basmala opens every surah, so
    /// following it on this page does not mean this is the surah being recited.
    private let neutral: Set<Int>
    private(set) var follower: Follower
    /// A word has been followed on this page by the follower itself: the reader is held to
    /// the text, and no longer looked for elsewhere.
    private(set) var held = false
    private var idle = 0

    init(page: Int, words: [String], neutral: Set<Int> = []) {
        self.page = page
        self.neutral = neutral
        follower = Follower(words: words)
    }

    var cursor: Int { follower.cursor }
    var isDone: Bool { follower.isDone }

    mutating func hear(_ hypothesis: String, final: Bool, locator: Locator?) -> Outcome {
        let moved = follower.feed(hypothesis, final: final)
        if !moved.isEmpty {
            if !moved.allSatisfy(neutral.contains) { held = true }
            idle = 0
            return .recited(moved)
        }
        var heard = Follower.words(of: hypothesis)
        if !final, !heard.isEmpty { heard.removeLast() }       // cut short, as in the follower
        guard heard.count >= 2 else { return .nothing }
        if !held, let locator, let place = locator.locate(heard) {
            // Not news when it is where the cursor already is: the last words of the page
            // before, still in the sound, or a phrase said again.
            let here = locator.position(page: page, index: cursor)
            let there = locator.position(page: place.page, index: place.index)
            if !(here - 10...here).contains(there) { return .elsewhere(place) }
        }
        // Not held yet, the reader may be anywhere - reciting another surah on the page, say,
        // while the locator waits for enough words to tell where - and is not stopped.
        guard held else { return .nothing }
        idle = follower.pending >= Self.unfitting ? idle + 1 : 0
        return idle >= Self.patience ? .stopped(at: cursor) : .nothing
    }

    /// Takes the reader up at a position: found there by the locator, or moved by hand. It
    /// does not hold them: a place the locator found is provisional until the follower itself
    /// advances from it, so a wrong one (a phrase that happens to be unique elsewhere) is
    /// undone by the next words rather than kept.
    mutating func begin(at index: Int) {
        follower.move(to: index)
        idle = 0
    }
}
