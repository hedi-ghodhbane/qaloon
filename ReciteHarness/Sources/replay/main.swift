import Foundation

// replay <stem>   (reads <stem>.hyps.json and <stem>.follow.json written by follow.py)
let stem = CommandLine.arguments[1]
func load(_ path: String) -> Any { try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: path))) }
let follow = load(stem + ".follow.json") as! [String: Any]
let rows = follow["words"] as! [[Any]]
let words = rows.map { $0[2] as! String }
let pythonWhen = rows.map { $0[3] as? Double }
let hyps = load(stem + ".hyps.json") as! [[Any]]

var follower = Follower(words: words)
var when = [Double?](repeating: nil, count: words.count)
for h in hyps {
    let now = (h[0] as! NSNumber).doubleValue, final = (h[1] as! NSNumber).boolValue, text = h[2] as! String
    let before = follower.cursor
    let moved = follower.feed(text, final: final)
    for k in moved where when[k] == nil { when[k] = now }
    if ProcessInfo.processInfo.environment["TRACE"] != nil, moved.lowerBound < before || follower.cursor < before {
        print(String(format: "%5.1f", now), final ? "F" : " ", "cursor \(before)->\(follower.cursor) moved \(moved) |", text.suffix(70))
    }
}
// Delay of the follower itself: from the first pass whose transcript holds the word (after the
// word before it was shown) to the pass that shows it. The model's own delay is not in it.
let skel = words.map(Skeleton.of)
var delays: [Double] = []
for k in words.indices {
    guard let shown = when[k] else { continue }
    let after = k > 0 ? (when[k - 1] ?? 0) : 0
    let first = hyps.first { h in
        let now = (h[0] as! NSNumber).doubleValue
        guard now >= after, now <= shown else { return false }
        return Follower.words(of: h[2] as! String).contains { Skeleton.similarity($0, skel[k]) >= Follower.same }
    }.map { ($0[0] as! NSNumber).doubleValue }
    if let first { delays.append(shown - first) }
}
delays.sort()
if !delays.isEmpty {
    print(String(format: "delay from first hearing to showing (s): median %.2f  p90 %.2f  mean %.2f  (%d words)",
                 delays[delays.count / 2], delays[min(delays.count - 1, delays.count * 9 / 10)],
                 delays.reduce(0, +) / Double(delays.count), delays.count))
}
let differ = zip(when, pythonWhen).enumerated().filter { $0.element.0 != $0.element.1 }
print("words \(words.count), cursor \(follower.cursor), words timed differently from Python: \(differ.count)")
for d in differ.prefix(8) { print("   #\(d.offset) \(words[d.offset]) swift \(String(describing: d.element.0)) python \(String(describing: d.element.1))") }
