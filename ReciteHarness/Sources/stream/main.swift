import Foundation
import WhisperKit

// stream <model folder> <stem> [hop seconds] [window seconds]
// The app's pipeline on a recording: every `hop` seconds the last `window` seconds go through
// the model and the result through the follower, as they would from a microphone.
let args = CommandLine.arguments
let modelFolder = args[1], stem = args[2]
let hop = args.count > 3 ? Double(args[3])! : 0.5
let window = args.count > 4 ? Double(args[4])! : 10.0
let rate = 16000.0

func load(_ path: String) -> Any { try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: path))) }
let rows = (load(stem + ".follow.json") as! [String: Any])["words"] as! [[Any]]
let words = rows.map { $0[2] as! String }
let ayahOf = rows.map { ($0[0] as! NSNumber).intValue }

let started = Date()
let kit = try await WhisperKit(WhisperKitConfig(modelFolder: modelFolder, tokenizerFolder: URL(fileURLWithPath: modelFolder),
                                                verbose: false, logLevel: .error, prewarm: false, load: true, download: false))
print(String(format: "model loaded in %.1f s", Date().timeIntervalSince(started)))
let options = DecodingOptions(task: .transcribe, language: "ar", temperature: 0, temperatureFallbackCount: 0,
                              usePrefillPrompt: true, detectLanguage: false, skipSpecialTokens: true,
                              withoutTimestamps: true, wordTimestamps: false)

let wav = try AudioProcessor.loadAudioAsFloatArray(fromPath: stem + ".wav")
let total = Double(wav.count) / rate
let level = (wav.reduce(0) { $0 + $1 * $1 } / Float(wav.count)).squareRoot()

var follower = Follower(words: words)
var when = [Double?](repeating: nil, count: words.count)
var cost: [Double] = [], hyps: [[Any]] = [], tokens: [Int] = []
var t = hop
while true {
    let now = min(t, total)
    let seg = Array(wav[max(0, Int((now - window) * rate))..<Int(now * rate)])
    let tail = seg.suffix(Int(0.35 * rate))
    let quiet = !tail.isEmpty && (tail.reduce(0) { $0 + $1 * $1 } / Float(tail.count)).squareRoot() < 0.15 * level
    let t0 = Date()
    let results = try await kit.transcribe(audioArray: seg, decodeOptions: options)
    cost.append(Date().timeIntervalSince(t0))
    tokens.append(results.reduce(0) { $0 + $1.segments.reduce(0) { $0 + $1.tokens.count } })
    let text = results.map(\.text).joined(separator: " ").trimmingCharacters(in: .whitespaces)
    let final = now >= total || quiet
    hyps.append([now, final, text])
    for k in follower.feed(text, final: final) where when[k] == nil { when[k] = now }
    if now >= total { break }
    t += hop
}

let timing = load(stem + ".timing.json") as! [[String: Any]]
var endOf: [Int: Double] = [:]
for r in timing { endOf[(r["ayah"] as! NSNumber).intValue] = (r["end_time"] as! NSNumber).doubleValue / 1000 }
var lastIndex: [Int: Int] = [:]
for (k, a) in ayahOf.enumerated() { lastIndex[a] = k }
var lags: [Double] = [], missing = 0
for (a, k) in lastIndex { if let e = endOf[a], e <= total { if let w = when[k] { lags.append(w - e) } else { missing += 1 } } }
lags.sort(); cost.sort()
func pick(_ v: [Double], _ q: Double) -> Double { v.isEmpty ? .nan : v[min(v.count - 1, Int(Double(v.count) * q))] }
print("cursor reached \(follower.cursor) / \(words.count) words; ayah ends followed \(lags.count), never reached \(missing)")
print(String(format: "lag at ayah ends (s): median %.1f  p90 %.1f  max %.1f", pick(lags, 0.5), pick(lags, 0.9), lags.last ?? .nan))
print(String(format: "model pass: median %.2f s  p90 %.2f s  max %.2f s  (%d passes); tokens per pass: mean %.0f", pick(cost, 0.5), pick(cost, 0.9), cost.last ?? .nan, cost.count, Double(tokens.reduce(0, +)) / Double(max(1, tokens.count))))
try JSONSerialization.data(withJSONObject: hyps).write(to: URL(fileURLWithPath: stem + ".hyps-coreml.json"))
