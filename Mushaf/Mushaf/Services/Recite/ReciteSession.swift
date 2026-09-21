import Foundation
import Observation
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

    enum Status: Equatable {
        case idle, loading, listening
        case failed(String)
    }

    private(set) var status: Status = .idle
    /// What the model last made of the sound: shown small, so a reader can tell it is hearing them.
    private(set) var heard = ""

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
    /// Seconds between passes, and of sound given to each.
    private static let hop = 0.5, window = 10.0

    private var kit: WhisperKit?
    private var follower = Follower(words: [])
    private var targets: [LayoutWord?] = []
    private var onHeard: (([LayoutWord]) -> Void)?
    private var onPageEnd: (() -> Void)?
    private var pageEnded = false
    private var loop: Task<Void, Never>?

    private let options = DecodingOptions(task: .transcribe, language: "ar", temperature: 0,
                                          temperatureFallbackCount: 0, usePrefillPrompt: true,
                                          detectLanguage: false, skipSpecialTokens: true,
                                          withoutTimestamps: true, wordTimestamps: false)

    /// Starts listening and follows `page`; `onHeard` gets the words each pass newly covers,
    /// `onPageEnd` is called once when the page's last word has been recited.
    func start(page: PageLayout, onHeard: @escaping ([LayoutWord]) -> Void, onPageEnd: @escaping () -> Void) {
        guard !isOn else { return }
        self.onHeard = onHeard
        self.onPageEnd = onPageEnd
        follow(page)
        status = .loading
        loop = Task { [weak self] in await self?.run() }
    }

    func stop() {
        loop?.cancel()
        loop = nil
        kit?.audioProcessor.stopRecording()
        heard = ""
        status = .idle
    }

    /// A new page, or the same one covered again: the text to follow starts over. The sound
    /// already heard is kept — a reader does not pause at a page turn.
    func follow(_ page: PageLayout) {
        let said = page.recitation
        targets = said.map(\.word)
        follower = Follower(words: said.map(\.text))
        pageEnded = false
    }

    /// The reader lifted this word's cover by hand: the recitation goes on from after it.
    func skip(past word: LayoutWord) {
        guard let k = targets.firstIndex(where: { $0?.key == word.key }), k >= follower.cursor else { return }
        follower.move(to: k + 1)
    }

    private func run() async {
        do {
            guard let folder = Self.modelFolder else {
                throw Failure("نموذج التسميع غير مثبّت على هذا الجهاز.")
            }
            guard await AudioProcessor.requestRecordPermission() else {
                throw Failure("اسمح للتطبيق باستعمال الميكروفون من إعدادات الجهاز.")
            }
            if kit == nil {
                kit = try await WhisperKit(WhisperKitConfig(modelFolder: folder.path, tokenizerFolder: folder,
                                                            verbose: false, logLevel: .error,
                                                            prewarm: false, load: true, download: false))
            }
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
        while !Task.isCancelled {
            try await Task.sleep(for: .seconds(Self.hop))
            let processor = kit.audioProcessor
            if processor.audioSamples.count > Self.rate * 40 {
                processor.purgeAudioSamples(keepingLast: Self.rate * Int(Self.window + 2))
            }
            let sound = Array(processor.audioSamples.suffix(Int(Self.window) * Self.rate))
            guard sound.count >= Self.rate else { continue }

            let tail = Self.loudness(sound.suffix(Self.rate * 35 / 100))
            level = max(level * 0.995, tail)
            let quiet = tail < max(0.15 * level, 0.002)
            if !quiet { lastVoice = Date() }
            guard let lastVoice, Date().timeIntervalSince(lastVoice) < Self.window else { continue }
            if quiet, settled { continue }
            settled = quiet

            let results = try await kit.transcribe(audioArray: sound, decodeOptions: options)
            let text = results.map(\.text).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !Task.isCancelled else { return }
            heard = text
            let moved = follower.feed(text, final: quiet)
            let words = moved.compactMap { targets[$0] }
            if !words.isEmpty { onHeard?(words) }
            if follower.isDone, !pageEnded {
                pageEnded = true
                onPageEnd?()
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
