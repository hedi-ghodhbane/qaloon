import Foundation

/// The consonant skeleton of an Arabic word: what is left once everything that the mushaf's
/// Uthmani Qaloun spelling and a speech recogniser's everyday spelling write differently is
/// gone. `ٱلصَّلَوٰةَ` and `الصلاة` both come out as `لصله`.
///
/// Long a is written three ways (alef, dagger alef, a waw or ya carrying one), so every alef
/// goes, and a waw or ya that only carries a dagger alef goes with it. Hamza seats, ta marbuta
/// and the final ya (`فِى` / `فِے` / `في`) are unified the same way.
enum Skeleton {
    static func of(_ word: String) -> String {
        let s = Array(word.unicodeScalars)
        var out = String.UnicodeScalarView()
        var i = 0
        while i < s.count {
            let c = s[i].value
            // الصلوٰة -> الصلة, موسىٰ -> موس
            if c == 0x0648 || c == 0x064A || c == 0x0649, i + 1 < s.count, s[i + 1].value == 0x0670 {
                i += 2
                continue
            }
            i += 1
            if isMark(c) { continue }
            switch c {
            case 0x0627, 0x0671, 0x0623, 0x0625, 0x0622,   // alef and its hamza forms
                 0x0649, 0x06D2,                             // alef maqsura, the Qaloun final ya
                 0x0621:                                     // free-standing hamza
                continue
            case 0x0624: out.append("\u{0648}")              // hamza on waw
            case 0x0626, 0x06CC: out.append("\u{064A}")      // hamza on ya, Farsi ya
            case 0x0629: out.append("\u{0647}")              // ta marbuta
            case 0x06A9: out.append("\u{0643}")
            default: out.append(s[i - 1])
            }
        }
        if out.count > 1, out.last == "\u{064A}" { out.removeLast() }
        return String(out)
    }

    /// Harakat, Quranic annotation signs (the rub' al-hizb star among them), tatweel, direction marks.
    private static func isMark(_ c: UInt32) -> Bool {
        (0x0610...0x061A).contains(c) || (0x064B...0x065F).contains(c) || c == 0x0670
            || (0x06D6...0x06ED).contains(c) || (0x08D3...0x08FF).contains(c)
            || c == 0x0640 || c == 0x200E || c == 0x200F
    }

    /// 1 − normalised edit distance between two skeletons.
    static func similarity(_ a: String, _ b: String) -> Double {
        if a == b { return 1 }
        let x = Array(a.unicodeScalars), y = Array(b.unicodeScalars)
        if x.isEmpty || y.isEmpty { return 0 }
        var prev = Array(0...y.count)
        for i in 1...x.count {
            var cur = [i]
            cur.reserveCapacity(y.count + 1)
            for j in 1...y.count {
                cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (x[i - 1] == y[j - 1] ? 0 : 1)))
            }
            prev = cur
        }
        return 1 - Double(prev[y.count]) / Double(max(x.count, y.count))
    }
}
