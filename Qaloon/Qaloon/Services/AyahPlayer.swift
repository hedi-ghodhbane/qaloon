import Foundation
import AVFoundation
import MediaPlayer
import Observation

/// Plays a range of ayahs with a reciter: consecutive ayahs of one surah are one
/// seek window in the surah MP3; the active ayah is tracked for highlighting.
/// Playback continues with the screen locked (audio background mode + `.playback`
/// session) and answers the lock-screen / headphone controls.
@MainActor
@Observable
final class AyahPlayer {
    static let shared = AyahPlayer()

    enum Status: Equatable {
        case idle, loading, playing, paused, error
    }

    struct RepeatInfo: Equatable {
        let current: Int
        let total: Int
    }

    private(set) var status: Status = .idle
    /// Ayah id currently sounding.
    private(set) var activeAyah: Int?
    private(set) var repeatInfo: RepeatInfo?
    private(set) var error: String?
    private(set) var rangeTitle = ""

    var isBusy: Bool { status == .loading || status == .playing || status == .paused }

    @ObservationIgnored private let player = AVPlayer()
    @ObservationIgnored private var run = 0
    @ObservationIgnored private var itemURL: URL?
    @ObservationIgnored private var itemEnded = false
    @ObservationIgnored private var endObserver: NSObjectProtocol?
    @ObservationIgnored private var remoteCommandsInstalled = false

    private struct Window {
        let id: Int
        let start: Double
        let end: Double
    }

    private struct Segment {
        let surah: Int
        let url: URL
        var start: Double
        var end: Double
        var ayahs: [Window]
        let timed: Bool
    }

    private init() {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.itemEnded = true }
        }
    }

    // MARK: - Controls

    /// Play ayahs `from…to` (inclusive ids) `times` times over.
    func play(from: Int, to: Int, times: Int = 1, reciter: Reciter) {
        stop()
        run += 1
        let run = self.run
        status = .loading
        error = nil
        rangeTitle = Quran.shared.rangeLabel(from: from, to: to)
        configureSession()
        installRemoteCommands()

        Task { [weak self] in
            guard let self else { return }
            do {
                let segments = try await self.buildSegments(from: from, to: to, reciter: reciter)
                guard run == self.run else { return }
                self.status = .playing
                self.updateNowPlaying(reciter: reciter)
                let total = max(1, times)
                for i in 1...total {
                    guard run == self.run else { return }
                    self.repeatInfo = RepeatInfo(current: i, total: total)
                    for segment in segments {
                        guard run == self.run else { return }
                        try await self.playSegment(segment, run: run)
                    }
                }
                if run == self.run { self.stop() }
            } catch {
                guard run == self.run else { return }
                self.player.pause()
                self.status = .error
                self.activeAyah = nil
                self.repeatInfo = nil
                self.error = (error as? LocalizedError)?.errorDescription ?? "تعذّر التشغيل."
            }
        }
    }

    func stop() {
        run += 1
        player.pause()
        status = .idle
        activeAyah = nil
        repeatInfo = nil
        #if os(macOS)
        MPNowPlayingInfoCenter.default().playbackState = .stopped
        #endif
    }

    func pause() {
        guard status == .playing else { return }
        player.pause()
        status = .paused
        #if os(macOS)
        MPNowPlayingInfoCenter.default().playbackState = .paused
        #endif
    }

    func resume() {
        guard status == .paused else { return }
        player.play()
        status = .playing
        #if os(macOS)
        MPNowPlayingInfoCenter.default().playbackState = .playing
        #endif
    }

    func togglePause() {
        if status == .paused { resume() } else { pause() }
    }

    // MARK: - Internals

    private func buildSegments(from: Int, to: Int, reciter: Reciter) async throws -> [Segment] {
        let quran = Quran.shared
        var out: [Segment] = []
        var current: Segment?
        for id in from...max(from, to) {
            let a = quran.ayah(id)
            if current == nil || current?.surah != a.surah {
                if let c = current { out.append(c) }
                current = Segment(surah: a.surah, url: reciter.surahURL(a.surah), start: 0, end: 0,
                                  ayahs: [], timed: reciter.timed)
            }
            guard let read = reciter.timingRead, var seg = current else { continue }
            let data = try await TimingService.shared.timings(read: read, surah: a.surah)
            guard data.numbering == .madani else { throw RecitationError.numbering(reciter.nameAr) }
            guard let t = data.timings.first(where: { $0.ayah == a.ayah }) else {
                throw RecitationError.missingTiming(a.surah, a.ayah)
            }
            if seg.ayahs.isEmpty { seg.start = t.start }
            seg.end = t.end
            seg.ayahs.append(Window(id: id, start: t.start, end: t.end))
            current = seg
        }
        if let c = current { out.append(c) }
        return out
    }

    private func playSegment(_ segment: Segment, run: Int) async throws {
        if itemURL != segment.url {
            player.replaceCurrentItem(with: AVPlayerItem(url: segment.url))
            itemURL = segment.url
        }
        itemEnded = false

        // Wait until the surah file is playable.
        let deadline = Date().addingTimeInterval(30)
        while let item = player.currentItem, item.status != .readyToPlay {
            guard run == self.run else { return }
            if item.status == .failed || Date() > deadline { throw RecitationError.loadFailed }
            try await Task.sleep(for: .milliseconds(50))
        }
        guard run == self.run else { return }

        let target = segment.timed ? segment.start : 0
        _ = await player.seek(to: CMTime(seconds: target, preferredTimescale: 1000),
                              toleranceBefore: .zero, toleranceAfter: .zero)
        guard run == self.run else { return }
        player.play()

        while true {
            guard run == self.run else { return }
            if status == .paused {
                try await Task.sleep(for: .milliseconds(150))
                continue
            }
            if let item = player.currentItem, item.status == .failed { throw RecitationError.loadFailed }
            let t = player.currentTime().seconds
            if segment.timed {
                if t >= segment.end - 0.05 {
                    player.pause()
                    return
                }
                if let hit = segment.ayahs.first(where: { t >= $0.start - 0.05 && t < $0.end }),
                   activeAyah != hit.id {
                    activeAyah = hit.id
                }
            } else if itemEnded {
                return
            }
            try await Task.sleep(for: .milliseconds(80))
        }
    }

    private func configureSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)
        #endif
    }

    private func installRemoteCommands() {
        guard !remoteCommandsInstalled else { return }
        remoteCommandsInstalled = true
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.resume() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.pause() }
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.togglePause() }
            return .success
        }
        center.stopCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in self?.stop() }
            return .success
        }
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
    }

    private func updateNowPlaying(reciter: Reciter) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: rangeTitle,
            MPMediaItemPropertyArtist: reciter.nameAr,
            MPMediaItemPropertyAlbumTitle: "المصحف برواية قالون",
        ]
        #if os(macOS)
        MPNowPlayingInfoCenter.default().playbackState = .playing
        #endif
    }
}
