import Foundation
import CoreGraphics

struct Surah: Identifiable, Hashable {
    let id: Int
    let nameAr: String
    let nameEn: String
    let ayahCount: Int
}

struct AyahRef: Hashable {
    /// Stable id 1…6214 in mushaf order (Madani count).
    let id: Int
    let surah: Int
    let ayah: Int
    let pageStart: Int
    let pageEnd: Int
}

struct PageRef: Hashable {
    let page: Int
    let lineCount: Int
    let juz: Int
    let hizb: Int
    /// Rub' al-hizb 1…240.
    let rub: Int
    /// First ayah with any text on this page (may have started on the page before).
    let firstAyahId: Int
    /// Last ayah with any text on this page (may continue onto the next page).
    let lastAyahId: Int
}

/// Qaloun mushaf reference data (King Fahd Complex edition, 604 pages), read
/// from the bundled `qaloun-index.json` produced by `npm run mushaf:build` and
/// copied here by `node scripts/build-native-data.mjs`.
final class Quran {
    static let shared = Quran()

    let surahs: [Surah]
    /// index = id - 1
    let ayahs: [AyahRef]
    /// index = page - 1
    let pages: [PageRef]
    /// Native pixel size of the page images the ayah boxes were measured on.
    let imageSize: CGSize
    /// [juz, hizb, quarter, ayahId, page] for the 240 rub' boundaries.
    private let divisions: [[Int]]
    private let idByKey: [Int: Int]

    var pageCount: Int { pages.count }
    var ayahCount: Int { ayahs.count }

    private struct File: Decodable {
        struct Image: Decodable {
            let width: Double
            let height: Double
        }
        let image: Image
        let surahs: [SurahRow]
        let ayahs: [[Int]]
        let pages: [[Int]]
        let divisions: [[Int]]
    }

    /// `[id, "الفاتحة", "Al-Fatiha", 7]`
    private struct SurahRow: Decodable {
        let id: Int
        let nameAr: String
        let nameEn: String
        let ayahCount: Int

        init(from decoder: Decoder) throws {
            var c = try decoder.unkeyedContainer()
            id = try c.decode(Int.self)
            nameAr = try c.decode(String.self)
            nameEn = try c.decode(String.self)
            ayahCount = try c.decode(Int.self)
        }
    }

    private init() {
        guard let url = Bundle.main.url(forResource: "qaloun-index", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(File.self, from: data)
        else {
            fatalError("qaloun-index.json is missing from the app bundle")
        }
        surahs = file.surahs.map {
            Surah(id: $0.id, nameAr: $0.nameAr, nameEn: $0.nameEn, ayahCount: $0.ayahCount)
        }
        ayahs = file.ayahs.enumerated().map { i, r in
            AyahRef(id: i + 1, surah: r[0], ayah: r[1], pageStart: r[2], pageEnd: r[3])
        }
        pages = file.pages.enumerated().map { i, r in
            PageRef(page: i + 1, lineCount: r[0], juz: r[1], hizb: r[2], rub: r[3],
                    firstAyahId: r[4], lastAyahId: r[5])
        }
        divisions = file.divisions
        imageSize = CGSize(width: file.image.width, height: file.image.height)
        var map: [Int: Int] = [:]
        for a in ayahs { map[a.surah * 1000 + a.ayah] = a.id }
        idByKey = map
    }

    func ayah(_ id: Int) -> AyahRef { ayahs[max(1, min(id, ayahs.count)) - 1] }
    func ayahId(surah: Int, ayah: Int) -> Int? { idByKey[surah * 1000 + ayah] }
    func page(_ p: Int) -> PageRef { pages[clampPage(p) - 1] }
    func surah(_ s: Int) -> Surah { surahs[max(1, min(s, surahs.count)) - 1] }
    func clampPage(_ p: Int) -> Int { max(1, min(p, pageCount)) }

    /// First page of juz 1…30.
    func juzStartPage(_ juz: Int) -> Int {
        divisions.first { $0[0] == juz && $0[2] == 1 && $0[1] % 2 == 1 }?[4] ?? 1
    }

    /// Pages covered by juz 1…30.
    func juzPageRange(_ juz: Int) -> ClosedRange<Int> {
        let from = juzStartPage(juz)
        let to = juz >= 30 ? pageCount : juzStartPage(juz + 1) - 1
        return from...max(from, to)
    }

    func surahStartPage(_ s: Int) -> Int {
        ayahId(surah: s, ayah: 1).map { ayah($0).pageStart } ?? 1
    }

    /// "البقرة ١٦"
    func label(ayahId id: Int) -> String {
        let a = ayah(id)
        return "\(surah(a.surah).nameAr) \(Self.arabicDigits(a.ayah))"
    }

    /// "البقرة ٥ – ١٦" or "آل عمران ٩٨ – النساء ٣"
    func rangeLabel(from: Int, to: Int) -> String {
        let a = ayah(from)
        let b = ayah(to)
        if a.surah == b.surah {
            if a.ayah == b.ayah { return label(ayahId: from) }
            return "\(surah(a.surah).nameAr) \(Self.arabicDigits(a.ayah)) – \(Self.arabicDigits(b.ayah))"
        }
        return "\(label(ayahId: from)) – \(label(ayahId: to))"
    }

    static func arabicDigits(_ n: Int) -> String {
        let digits: [Character] = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        return String(String(n).map { ch -> Character in
            if let d = ch.wholeNumberValue, (0...9).contains(d) { return digits[d] }
            return ch
        })
    }

    /// Ayahs per surah in the Hafs (Kufi) count, used to recognise Hafs-numbered timing data.
    static let hafsAyahCounts: [Int] = [
        7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111,
        110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45,
        83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55,
        78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20,
        56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21,
        11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6,
    ]
}

extension Quran: @unchecked Sendable {}
