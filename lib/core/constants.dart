/// Total pages in a standard Mushaf.
const kTotalPages = 604;

/// Default image native width for Qaloun images from maknon/Quran (1110px PNGs).
const kQalounImageNativeWidth = 1110;

/// Default Riwaya ID for Qaloun.
const kQalounRiwayaId = 1;

/// Riwaya keys used in the database and file paths.
abstract final class RiwayaKeys {
  static const qaloun = 'qaloun';
  static const warsh = 'warsh';
  static const hafs = 'hafs';
}
