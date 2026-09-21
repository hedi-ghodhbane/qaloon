import SwiftUI

/// Ertak's parchment palette (see src/styles.css).
enum Theme {
    static let parchment = Color(red: 247 / 255, green: 240 / 255, blue: 225 / 255)
    static let parchmentDeep = Color(red: 236 / 255, green: 226 / 255, blue: 204 / 255)
    static let green = Color(red: 31 / 255, green: 81 / 255, blue: 54 / 255)
    static let gold = Color(red: 184 / 255, green: 146 / 255, blue: 62 / 255)
    static let ink = Color(red: 43 / 255, green: 42 / 255, blue: 38 / 255)
    static let inkSoft = Color(red: 107 / 255, green: 102 / 255, blue: 92 / 255)
    static let line = Color(red: 31 / 255, green: 81 / 255, blue: 54 / 255).opacity(0.18)

    /// Ayah the reader tapped.
    static let selected = green.opacity(0.16)
    /// Ayah being recited.
    static let playing = gold.opacity(0.32)
    /// Underline marking a hidden ayah (the cover itself is `parchment`, invisible over the transparent page PNGs).
    static let coverLine = gold.opacity(0.5)
}
