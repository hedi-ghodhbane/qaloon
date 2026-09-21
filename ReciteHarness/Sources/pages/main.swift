import Foundation

// pages <hyps.json> <first page>
// The reader view's hide-mode flow driven by saved hypotheses: words heard lose their cover,
// a page with no cover left turns 0.9 s later, and the follower goes on with the next page.
let hyps = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[Any]]
var page = Int(CommandLine.arguments[2])!
let startAt = CommandLine.arguments.count > 3 ? Double(CommandLine.arguments[3])! : 0   // the reader begins here, mid-page
let keepOpening = true

var layout = LayoutStore.shared.layout(for: page)
var said = layout.recitation
var follower = Follower(words: said.map(\.text))
var revealed: Set<Int> = []
var turnAt: Double?
var firstHeard: Double?

func report(_ now: Double) {
    let hideable = layout.hideableWords(keepOpening: keepOpening)
    let left = hideable.filter { !revealed.contains($0.key) }
    let where_ = left.prefix(3).map { w in "\(layout.ayahs.first { $0.id == w.ayahId }!.ayah):\(w.index)" }
    print(String(format: "page %d: %d of %d covers lifted by %.1f s (first at %.1f s); recited sequence %d words, cursor %d%@",
                 page, hideable.count - left.count, hideable.count, now, firstHeard ?? -1, said.count, follower.cursor,
                 left.isEmpty ? "" : "; still covered from \(where_)"))
}

for h in hyps {
    let now = (h[0] as! NSNumber).doubleValue, final = (h[1] as! NSNumber).boolValue, text = h[2] as! String
    if now < startAt { continue }
    if let t = turnAt, now >= t {
        report(now)
        page += 1
        layout = LayoutStore.shared.layout(for: page)
        said = layout.recitation
        follower = Follower(words: said.map(\.text))
        revealed = []; turnAt = nil; firstHeard = nil
    }
    let moved = follower.feed(text, final: final)
    let keys = moved.compactMap { said[$0].word?.key }
    if !keys.isEmpty, firstHeard == nil { firstHeard = now }
    revealed.formUnion(keys)
    let left = layout.hideableWords(keepOpening: keepOpening).filter { !revealed.contains($0.key) }
    if left.isEmpty, !revealed.isEmpty, turnAt == nil { turnAt = now + 0.9 }
}
report((hyps.last![0] as! NSNumber).doubleValue)
