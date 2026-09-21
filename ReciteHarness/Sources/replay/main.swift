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
let differ = zip(when, pythonWhen).enumerated().filter { $0.element.0 != $0.element.1 }
print("words \(words.count), cursor \(follower.cursor), words timed differently from Python: \(differ.count)")
for d in differ.prefix(8) { print("   #\(d.offset) \(words[d.offset]) swift \(String(describing: d.element.0)) python \(String(describing: d.element.1))") }
