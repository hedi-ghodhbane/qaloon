import SwiftUI

/// المصحف — a stand-alone Qaloun mushaf reader (iPhone, iPad, Mac).
///
/// Same data as Ertak's web reader (page images from the CDN, ayah boxes from
/// `layout.json`), no account: the last page, reciter and options live in
/// UserDefaults; opened pages are kept on disk for offline reading.
@main
struct MushafApp: App {
    var body: some Scene {
        WindowGroup {
            ReaderView()
                .environment(\.layoutDirection, .rightToLeft)
                .tint(Theme.green)
                .preferredColorScheme(.light)
                #if os(macOS)
                .frame(minWidth: 380, minHeight: 600)
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 560, height: 900)
        #endif
    }
}
