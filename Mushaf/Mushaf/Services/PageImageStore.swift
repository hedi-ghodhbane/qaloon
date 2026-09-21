import Foundation
import CoreGraphics
import ImageIO
import Observation

/// Page images (King Fahd Complex Qaloun PNGs from cdn.makeathar.com).
///
/// Every page that is shown is written to Application Support and read from
/// there afterwards, so the mushaf works offline and never re-downloads; a
/// small in-memory cache keeps the decoded neighbours of the current page.
@MainActor
@Observable
final class PageImageStore {
    static let shared = PageImageStore()
    nonisolated static let cdnBase = URL(string: "https://cdn.makeathar.com/kf/")!

    struct DownloadProgress: Equatable {
        let done: Int
        let total: Int
    }

    /// Pages present on disk.
    private(set) var downloaded: Set<Int> = []
    private(set) var downloading = false
    private(set) var downloadProgress: DownloadProgress?

    @ObservationIgnored private let memory = NSCache<NSNumber, CGImage>()
    @ObservationIgnored private var inflight: [Int: Task<CGImage?, Never>] = [:]
    @ObservationIgnored private var downloadTask: Task<Void, Never>?
    @ObservationIgnored private let directory: URL

    private init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        directory = base.appendingPathComponent("Mushaf/pages", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        memory.countLimit = 8
        if let names = try? FileManager.default.contentsOfDirectory(atPath: directory.path) {
            downloaded = Set(names.compactMap { Int($0.split(separator: ".").first ?? "") })
        }
    }

    nonisolated static func remoteURL(for page: Int) -> URL {
        cdnBase.appendingPathComponent("\(page).png")
    }

    func fileURL(for page: Int) -> URL {
        directory.appendingPathComponent("\(page).png")
    }

    func isDownloaded(_ page: Int) -> Bool { downloaded.contains(page) }

    func downloadedCount(in pages: ClosedRange<Int>) -> Int {
        pages.reduce(0) { $0 + (downloaded.contains($1) ? 1 : 0) }
    }

    /// Bytes the stored pages take on disk.
    func storedBytes() -> Int64 {
        downloaded.reduce(Int64(0)) { total, p in
            let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL(for: p).path)
            return total + ((attrs?[.size] as? NSNumber)?.int64Value ?? 0)
        }
    }

    /// Delete every stored page (they are fetched again when opened).
    func removeAllStored() {
        cancelDownload()
        for p in downloaded {
            try? FileManager.default.removeItem(at: fileURL(for: p))
        }
        downloaded = []
        memory.removeAllObjects()
    }

    private func markStored(_ page: Int) {
        if FileManager.default.fileExists(atPath: fileURL(for: page).path) {
            downloaded.insert(page)
        }
    }

    /// Decoded image for `page`: memory → disk → CDN (then kept on disk).
    func image(for page: Int) async -> CGImage? {
        if let hit = memory.object(forKey: NSNumber(value: page)) { return hit }
        if let task = inflight[page] { return await task.value }
        let file = fileURL(for: page)
        let remote = Self.remoteURL(for: page)
        let task = Task<CGImage?, Never> {
            guard let data = await Self.loadData(file: file, remote: remote) else { return nil }
            return await Task.detached(priority: .userInitiated) { Self.decode(data) }.value
        }
        inflight[page] = task
        let image = await task.value
        inflight[page] = nil
        if let image {
            memory.setObject(image, forKey: NSNumber(value: page))
            markStored(page)
        }
        return image
    }

    /// Warm the pages the reader is likely to turn to next.
    func prefetch(around page: Int) {
        for p in [page + 1, page - 1, page + 2] where p >= 1 && p <= Quran.shared.pageCount {
            Task { _ = await image(for: p) }
        }
    }

    /// Disk first; otherwise fetch from the CDN and keep the file for good.
    nonisolated private static func loadData(file: URL, remote: URL) async -> Data? {
        if let data = try? Data(contentsOf: file) { return data }
        guard let (data, response) = try? await URLSession.shared.data(from: remote) else { return nil }
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) { return nil }
        try? data.write(to: file, options: .atomic)
        return data
    }

    nonisolated static func decode(_ data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [kCGImageSourceShouldCache: true]
        return CGImageSourceCreateImageAtIndex(source, 0, options as CFDictionary)
    }

    // MARK: - Offline download

    /// Store `pages` on disk (skipping those already there), four at a time.
    func downloadForOffline(_ pages: [Int]) {
        cancelDownload()
        let todo = pages.filter { !downloaded.contains($0) }
        var done = pages.count - todo.count
        downloadProgress = DownloadProgress(done: done, total: pages.count)
        downloading = true
        let files = Dictionary(uniqueKeysWithValues: todo.map { ($0, fileURL(for: $0)) })
        downloadTask = Task { [weak self] in
            var index = 0
            while index < todo.count, !Task.isCancelled {
                let batch = Array(todo[index..<min(index + 4, todo.count)])
                index += 4
                await withTaskGroup(of: Int?.self) { group in
                    for p in batch {
                        guard let file = files[p] else { continue }
                        group.addTask {
                            await Self.loadData(file: file, remote: Self.remoteURL(for: p)) != nil ? p : nil
                        }
                    }
                    for await result in group {
                        guard let self else { return }
                        if let p = result { self.markStored(p) }
                        done += 1
                        self.downloadProgress = DownloadProgress(done: done, total: pages.count)
                    }
                }
            }
            self?.downloading = false
        }
    }

    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        downloading = false
    }
}
