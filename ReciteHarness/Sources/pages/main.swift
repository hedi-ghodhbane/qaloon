import Foundation

// pages <hyps.json> <page on screen> [start seconds] [cut from] [cut to]
// The reader view's hide-mode flow driven by saved hypotheses, as the app's listener runs it:
// words heard lose their cover, a reader who is elsewhere is found (and the page changed), a
// page with no cover left turns 0.9 s later, a reader who leaves words out is stopped.
//   start seconds   the reader begins here: mid-page, or in a surah that is not on screen
//   cut from/to     the reader leaves this stretch out
let args = CommandLine.arguments
let hyps = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: args[1]))) as! [[Any]]
var page = Int(args[2])!
let startAt = args.count > 3 ? Double(args[3])! : 0
let cut = args.count > 5 ? Double(args[4])!..<Double(args[5])! : nil
let keepOpening = true

let locator = Locator(pages: (1...604).map { LayoutStore.shared.layout(for: $0).recitation.map(\.text) })
var layout = LayoutStore.shared.layout(for: page)
var said = layout.recitation
var tracker = Tracker(page: page, words: said.map(\.text), neutral: Set(said.indices.filter { said[$0].word == nil }))
var settled = false
var revealed: Set<Int> = []
var turnAt: Double?, firstHeard: Double?, stoppedSince: Double?, recited = 0

func show(_ p: Int) {
    page = p
    layout = LayoutStore.shared.layout(for: p)
    said = layout.recitation
    tracker = Tracker(page: p, words: said.map(\.text), neutral: Set(said.indices.filter { said[$0].word == nil }))
    revealed = []; turnAt = nil; firstHeard = nil; stoppedSince = nil
}

func label(_ index: Int) -> String {
    guard index < said.count, let w = said[index].word, let a = layout.ayahs.first(where: { $0.id == w.ayahId }) else { return "end" }
    return "\(a.surah):\(a.ayah) word \(w.index) \(w.text)"
}

func report(_ now: Double) {
    let hideable = layout.hideableWords(keepOpening: keepOpening)
    let left = hideable.filter { !revealed.contains($0.key) }
    // The rule: nothing shown after a covered word.
    let order = said.compactMap(\.word).filter { $0.isHideable(keepOpening: keepOpening) }
    let firstCovered = order.firstIndex { !revealed.contains($0.key) } ?? order.count
    let broken = order[firstCovered...].contains { revealed.contains($0.key) }
    print(String(format: "page %d: %d of %d covers lifted by %.1f s (first at %.1f s), cursor %d of %d, %d words counted as recited%@%@",
                 page, hideable.count - left.count, hideable.count, now, firstHeard ?? -1, tracker.cursor, said.count, recited,
                 left.isEmpty ? "" : "; next covered: \(label(tracker.cursor))",
                 broken ? "  ** A WORD IS SHOWN AFTER A COVERED ONE **" : ""))
}

for h in hyps {
    let now = (h[0] as! NSNumber).doubleValue, final = (h[1] as! NSNumber).boolValue, text = h[2] as! String
    if now < startAt { continue }
    if let cut, cut.contains(now) { continue }
    if let t = turnAt, now >= t { report(now); show(page + 1) }
    // As the listener does: a pause is read once, then nothing until the voice is back.
    if final, settled { continue }
    settled = final

    func begin(_ place: Locator.Place) {
        tracker.begin(at: place.index)
        revealed.formUnion(said[..<place.index].compactMap { $0.word?.key })
        recited += place.run
        if firstHeard == nil { firstHeard = now }
        print(String(format: "  %.1f s: found on page %d at %@ (by %d words)", now, place.page, label(place.index), place.run))
    }
    switch tracker.hear(text, final: final, locator: locator) {
    case .nothing: break
    case .recited(let range):
        revealed.formUnion(said[range].compactMap { $0.word?.key })
        recited += range.count
        if firstHeard == nil { firstHeard = now }
        stoppedSince = nil
    case .elsewhere(let place):
        if place.page != page { report(now); show(place.page) }
        begin(place)
    case .stopped(let index):
        if stoppedSince == nil { stoppedSince = now; print(String(format: "  %.1f s: stopped at %@", now, label(index))) }
    }
    let left = layout.hideableWords(keepOpening: keepOpening).filter { !revealed.contains($0.key) }
    if left.isEmpty, !revealed.isEmpty, turnAt == nil { turnAt = now + 0.9 }
}
report((hyps.last![0] as! NSNumber).doubleValue)
