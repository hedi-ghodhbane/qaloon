/// Total pages in a standard Mushaf.
const kTotalPages = 604;

/// Pages bundled in the APK (1–30). Rest downloaded on first launch.
const kBundledPages = 30;

/// Default image native width for Qaloun images (GoldenQuranRes 1260px PNGs).
const kQalounImageNativeWidth = 1260;

/// CDN base URL for Qaloun page images via jsDelivr → your GitHub repo.
/// Pages are zero-padded: page001.png to page604.png.
const kQalounPagesBaseUrl =
    'https://cdn.jsdelivr.net/gh/hedi-ghodhbane/qaloon-assets@main/pages';

/// Default Riwaya ID for Qaloun.
const kQalounRiwayaId = 1;

/// Riwaya keys used in the database and file paths.
abstract final class RiwayaKeys {
  static const qaloun = 'qaloun';
  static const warsh = 'warsh';
  static const hafs = 'hafs';
}
