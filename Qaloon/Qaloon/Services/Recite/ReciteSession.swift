import Foundation
import Observation
import OSLog
import WhisperKit

/// Listens to the reader and follows the recitation through the page: twice a second the last
/// few seconds of sound go through a Whisper model fine-tuned on Quran recitation
/// (tarteel-ai/whisper-base-ar-quran, Apache-2.0, converted to Core ML — see
/// `scripts/build-recite-model.sh`), and the result through a `Follower` that knows the page's
/// words. Everything runs on the device; no sound leaves it.
@MainActor
@Observable
final class ReciteSession {
    static let shared = ReciteSession()
    private static let log = Logger(subsystem: "com.makeathar.mushaf", category: "recite")

    enum Status: Equatable {
        case idle, loading, listening
        case failed(String)
    }

    private(set) var status: Status = .idle
    /// Seconds spent so far getting the model ready (shown while it takes a while).
    private(set) var preparing = 0.0
    /// What the model last made of the sound: shown small, so a reader can tell it is hearing them.
    private(set) var heard = ""
    /// The word a reader is stopped at: they go on speaking, and it is not what they say.
    private(set) var stoppedAt: LayoutWord?
    /// How long the model's last pass took: shown small, so a slow device can be told apart
    /// from a follower that will not move.
    private(set) var passSeconds = 0.0

    var isOn: Bool { status == .listening || status == .loading }

    /// The Core ML model and its tokenizer: in the app bundle, or in Application Support
    /// (`Mushaf/ReciteModel`) when it was put or downloaded there.
    static var modelFolder: URL? {
        let fm = FileManager.default
        var places: [URL] = []
        if let bundled = Bundle.main.resourceURL {
            places += [bundled.appendingPathComponent("ReciteModel", isDirectory: true), bundled]
        }
        if let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            places.append(support.appendingPathComponent("Mushaf/ReciteModel", isDirectory: true))
        }
        return places.first { fm.fileExists(atPath: $0.appendingPathComponent("TextDecoder.mlmodelc").path) }
    }

    static var isAvailable: Bool { modelFolder != nil }

    private static let rate = 16_000
    /// Seconds between the starts of passes (a slow device goes straight on), and of sound
    /// given to each. Less sound would decode faster (6 s: 31 tokens for 44, 50 ms on a Mac)
    /// but the model then mishears words it gets right with more context, and a follower held
    /// to the text cannot pass a misheard word: on the recordings it stalled.
    private static let hop = 0.4, window = 10.0

    /// What the reader view does for the listener.
    struct Handlers {
        /// Lift these words' covers.
        var lift: ([LayoutWord]) -> Void
        /// The page's last word has been recited.
        var pageEnd: () -> Void
        /// The reader is reciting another page: show it.
        var go: (Int) -> Void
    }

    private var kit: WhisperKit?
    private var locator: Locator?
    /// The model being got ready: loaded, and compiled for the Neural Engine by Core ML —
    /// once per install (8 s on a Mac, longer on a phone), cached after that.
    private var preparingKit: Task<WhisperKit, Error>?
    private var tracker = Tracker(page: 1, words: [])
    private var said: [(text: String, word: LayoutWord?)] = []
    private var handlers: Handlers?
    /// Where to take the reader up once the page the locator found them on is shown.
    private var arriving: Locator.Place?
    private var pageEnded = false
    private var loop: Task<Void, Never>?

    private let options = DecodingOptions(task: .transcribe, language: "ar", temperature: 0,
                                          temperatureFallbackCount: 0, usePrefillPrompt: true,
                                          detectLanguage: false, skipSpecialTokens: true,
                                          withoutTimestamps: true, wordTimestamps: false)

    /// Gets the model ready in the background, so «سمِّع» is instant: called when hide
    /// mode is on. The first time after an install this is Core ML compiling the model for
    /// the Neural Engine, which is what took so long under «تحميل…».
    func warmUp() {
        guard Self.isAvailable, kit == nil, preparingKit == nil else { return }
        preparingKit = Task.detached(priority: .utility) { [folder = Self.modelFolder!] in
            let started = Date()
            let kit = try await WhisperKit(WhisperKitConfig(modelFolder: folder.path, tokenizerFolder: folder,
                                                            verbose: false, logLevel: .error,
                                                            prewarm: true, load: true, download: false))
            Self.log.notice("model ready in \(Date().timeIntervalSince(started), format: .fixed(precision: 1)) s (specialisation \(kit.currentTimings.prewarmLoadTime, format: .fixed(precision: 1)) s)")
            return kit
        }
        if locator == nil {
            Task.detached(priority: .utility) {
                let built = Locator(pages: (1...Quran.shared.pageCount).map { LayoutStore.shared.layout(for: $0).recitation.map(\.text) })
                await MainActor.run { ReciteSession.shared.locator = built }
            }
        }
    }

    /// Lets the model go (150 MB of memory): hide mode is off, and it would not be used.
    func release() {
        guard !isOn else { return }
        preparingKit?.cancel()
        preparingKit = nil
        kit = nil
    }

    /// Starts listening, and follows `page` until the reader is heard to be elsewhere.
    func start(page: PageLayout, handlers: Handlers) {
        guard !isOn else { return }
        self.handlers = handlers
        follow(page)
        status = .loading
        loop = Task { [weak self] in await self?.run() }
    }

    func stop() {
        loop?.cancel()
        loop = nil
        kit?.audioProcessor.stopRecording()
        heard = ""
        stoppedAt = nil
        arriving = nil
        status = .idle
        ReciteStats.shared.flush()
    }

    /// A new page, or the same one covered again: the text to follow starts over. The sound
    /// already heard is kept — a reader does not pause at a page turn.
    func follow(_ page: PageLayout) {
        said = page.recitation
        tracker = Tracker(page: page.page, words: said.map(\.text),
                          neutral: Set(said.indices.filter { said[$0].word == nil }))
        pageEnded = false
        stoppedAt = nil
        if let place = arriving, place.page == page.page { begin(at: place) }
        arriving = nil
    }

    /// The reader lifted this word's cover by hand: the recitation goes on from after it.
    func skip(past word: LayoutWord) {
        guard let k = said.firstIndex(where: { $0.word?.key == word.key }), k >= tracker.cursor else { return }
        tracker.begin(at: k + 1)
        stoppedAt = nil
    }

    /// Takes the reader up where the locator heard them. What comes before on the page is
    /// shown — it is where they chose to start, not something they left out — and the words
    /// they were found by count as recited.
    private func begin(at place: Locator.Place) {
        tracker.begin(at: place.index)
        handlers?.lift(said[..<place.index].compactMap(\.word))
        recited(max(0, place.index - place.run)..<place.index)
    }

    private func recited(_ range: Range<Int>) {
        ReciteStats.shared.record(words: said[range].map(\.text), pageWords: said.count)
    }

    private func run() async {
        do {
            guard let folder = Self.modelFolder else {
                throw Failure("نموذج التسميع غير مثبّت على هذا الجهاز.")
            }
            guard await AudioProcessor.requestRecordPermission() else {
                throw Failure("اسمح للتطبيق باستعمال الميكروفون من إعدادات الجهاز.")
            }
            _ = folder
            if kit == nil {
                warmUp()
                let started = Date()
                let ticking = Task { [weak self] in
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .milliseconds(250))
                        self?.preparing = Date().timeIntervalSince(started)
                    }
                }
                defer { ticking.cancel(); preparing = 0 }
                kit = try await preparingKit?.value
                preparingKit = nil
            }
            while locator == nil, !Task.isCancelled { try await Task.sleep(for: .milliseconds(100)) }
            guard let kit, !Task.isCancelled else { return }
            AyahPlayer.shared.stop()
            kit.audioProcessor.purgeAudioSamples(keepingLast: 0)
            try kit.audioProcessor.startRecordingLive(inputDeviceID: nil, callback: nil)
            status = .listening
            try await listen(kit)
        } catch is CancellationError {
        } catch {
            kit?.audioProcessor.stopRecording()
            status = .failed((error as? Failure)?.message ?? error.localizedDescription)
        }
    }

    private func listen(_ kit: WhisperKit) async throws {
        var level: Float = 0          // how loud this reader's voice gets: the measure of a pause
        var settled = false           // the pause has already been read once: nothing new to hear
        var lastVoice: Date?          // Whisper makes words up out of silence: it is given none
        var nextAt = Date()
        while !Task.isCancelled {
            // Passes are paced from their starts: a pass slower than the hop is followed at once.
            let wait = nextAt.timeIntervalSinceNow
            if wait > 0 { try await Task.sleep(for: .seconds(wait)) }
            nextAt = Date().addingTimeInterval(Self.hop)
            let processor = kit.audioProcessor
            if processor.audioSamples.count > Self.rate * 40 {
                processor.purgeAudioSamples(keepingLast: Self.rate * Int(Self.window + 2))
            }
            let sound = Array(processor.audioSamples.suffix(Int(Self.window) * Self.rate))
            guard sound.count >= Self.rate else { continue }

            let tail = Self.loudness(sound.suffix(Self.rate * 35 / 100))
            level = max(level * 0.995, tail)
            let quiet = tail < max(0.15 * level, 0.002)
            if !quiet {
                lastVoice = Date()
                ReciteStats.shared.record(seconds: Self.hop)
            }
            guard let lastVoice, Date().timeIntervalSince(lastVoice) < Self.window else { continue }
            if quiet, settled { continue }
            settled = quiet

            let started = Date()
            let results = try await kit.transcribe(audioArray: sound, decodeOptions: options)
            let text = results.map(\.text).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !Task.isCancelled else { return }
            passSeconds = Date().timeIntervalSince(started)
            heard = text
            switch tracker.hear(text, final: quiet, locator: locator) {
            case .nothing:
                break
            case .recited(let range):
                stoppedAt = nil
                handlers?.lift(said[range].compactMap(\.word))
                recited(range)
            case .elsewhere(let place):
                if place.page == tracker.page {
                    begin(at: place)
                } else {
                    arriving = place
                    handlers?.go(place.page)      // the view shows the page, then calls `follow`
                }
            case .stopped(let index):
                stoppedAt = index < said.count ? said[index].word : nil
            }
            if tracker.isDone, !pageEnded {
                pageEnded = true
                stoppedAt = nil
                handlers?.pageEnd()
            }
        }
    }

    private static func loudness(_ samples: ArraySlice<Float>) -> Float {
        guard !samples.isEmpty else { return 0 }
        return (samples.reduce(0) { $0 + $1 * $1 } / Float(samples.count)).squareRoot()
    }

    private struct Failure: Error {
        let message: String
        init(_ message: String) { self.message = message }
    }
}
