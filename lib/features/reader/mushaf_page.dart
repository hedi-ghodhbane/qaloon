import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';
import '../../core/models/page_glyph.dart';
import '../../core/providers/bookmark_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../core/providers/riwaya_providers.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'glyph_overlay.dart';

class MushafPage extends ConsumerStatefulWidget {
  final int pageNumber;
  final int riwayaId;
  final String riwayaKey;
  final int imageNativeWidth;
  final bool isBundled;
  final VoidCallback? onBackgroundTap;

  const MushafPage({
    super.key,
    required this.pageNumber,
    required this.riwayaId,
    required this.riwayaKey,
    required this.imageNativeWidth,
    this.isBundled = false,
    this.onBackgroundTap,
  });

  @override
  ConsumerState<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends ConsumerState<MushafPage> {
  final Set<AyahKey> _selectedAyahs = {};
  final Set<AyahKey> _hiddenAyahs = {};
  String? _imagePath;
  bool _pathReady = false;

  bool get _isBundledPage => widget.isBundled && widget.pageNumber <= kBundledPages;

  @override
  void initState() {
    super.initState();
    if (_isBundledPage) {
      _pathReady = true;
    } else {
      _resolveImagePath();
    }
    // Listen for toolbar actions (hide all, show all, hide selected).
    ref.listenManual(readerActionProvider, (prev, action) {
      if (action == null) return;
      switch (action) {
        case ReaderAction.hideAll:
          hideAllAyahs();
        case ReaderAction.showAll:
          showAll();
        case ReaderAction.hideSelected:
          hideSelected();
        case ReaderAction.showNext:
          _showNextAyah();
        case ReaderAction.hideNext:
          _hideNextAyah();
      }
      // Reset after frame so it can fire again.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(readerActionProvider.notifier).state = null;
        }
      });
    });
  }

  /// Asset path for bundled riwaya pages (1–kBundledPages).
  String get _assetPath =>
      'assets/pages/${widget.riwayaKey}_bundled/${widget.pageNumber}.png';

  Future<void> _resolveImagePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/riwaya_${widget.riwayaKey}/${widget.pageNumber}.png';
    if (mounted) {
      setState(() {
        _imagePath = path;
        _pathReady = true;
      });
    }
  }

  void _onAyahTap(PageGlyph glyph) {
    final mode = ref.read(readerModeProvider);
    final key = glyph.ayahKey;

    setState(() {
      // Always reveal hidden ayahs on tap, regardless of mode.
      if (_hiddenAyahs.contains(key)) {
        _hiddenAyahs.remove(key);
        _syncHiddenState();
        if (_hiddenAyahs.isEmpty && mode == ReaderMode.hidePage) {
          ref.read(readerModeProvider.notifier).state = ReaderMode.normal;
        }
        return;
      }

      switch (mode) {
        case ReaderMode.normal:
          if (_selectedAyahs.contains(key)) {
            _selectedAyahs.clear();
          } else {
            _selectedAyahs
              ..clear()
              ..add(key);
          }
        case ReaderMode.hidePage:
          // Nothing to do — hidden reveal handled above.
          break;
        case ReaderMode.select:
          if (_selectedAyahs.contains(key)) {
            _selectedAyahs.remove(key);
          } else {
            _selectedAyahs.add(key);
          }
      }
    });
  }

  void _onAyahLongPress(PageGlyph glyph) {
    final key = glyph.ayahKey;
    final isHidden = _hiddenAyahs.contains(key);
    final bookmark = ref.read(bookmarkNotifierProvider).valueOrNull;
    final isBookmarked = bookmark != null &&
        bookmark.pageNumber == widget.pageNumber &&
        bookmark.surahId == glyph.surahId &&
        bookmark.ayahNumber == glyph.ayahNumber;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'سورة ${glyph.surahId} : آية ${glyph.ayahNumber}',
                  style: const TextStyle(
                    fontFamily: 'Noto Naskh Arabic',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Bookmark
              ListTile(
                leading: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked ? const Color(0xFFCDA34F) : null,
                ),
                title: Text(isBookmarked ? 'إزالة العلامة' : 'حفظ علامة هنا'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (isBookmarked) {
                    ref.read(bookmarkNotifierProvider.notifier).clearBookmark();
                  } else {
                    ref.read(bookmarkNotifierProvider.notifier).setBookmark(
                          pageNumber: widget.pageNumber,
                          surahId: glyph.surahId,
                          ayahNumber: glyph.ayahNumber,
                          riwayaId: widget.riwayaId,
                        );
                  }
                },
              ),
              // Hide / Show ayah
              ListTile(
                leading: Icon(
                  isHidden ? Icons.visibility : Icons.visibility_off_outlined,
                ),
                title: Text(isHidden ? 'إظهار الآية' : 'إخفاء الآية'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    if (isHidden) {
                      _hiddenAyahs.remove(key);
                    } else {
                      _hiddenAyahs.add(key);
                    }
                    _syncHiddenState();
                  });
                },
              ),
              // Hide all page
              ListTile(
                leading: const Icon(Icons.visibility_off),
                title: const Text('إخفاء كل الصفحة'),
                onTap: () {
                  Navigator.pop(ctx);
                  hideAllAyahs();
                  ref.read(readerModeProvider.notifier).state =
                      ReaderMode.hidePage;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get all unique ayah keys on this page from the current glyphs.
  Set<AyahKey> _allAyahKeysOnPage() {
    final glyphs = ref
        .read(glyphsForPageProvider((
          pageNumber: widget.pageNumber,
          riwayaId: widget.riwayaId,
          screenWidth: widget.imageNativeWidth.toDouble(),
          imageNativeWidth: widget.imageNativeWidth,
        )))
        .valueOrNull;
    if (glyphs == null) return {};
    return glyphs.map((g) => g.ayahKey).toSet();
  }

  /// Called by ReaderScreen when entering hidePage mode.
  void _syncHiddenState() {
    ref.read(hasHiddenAyahsProvider.notifier).state = _hiddenAyahs.isNotEmpty;
  }

  void hideAllAyahs() {
    setState(() {
      _hiddenAyahs.addAll(_allAyahKeysOnPage());
      _selectedAyahs.clear();
    });
    _syncHiddenState();
  }

  void hideSelected() {
    setState(() {
      _hiddenAyahs.addAll(_selectedAyahs);
      _selectedAyahs.clear();
    });
    _syncHiddenState();
  }

  void showAll() {
    setState(() {
      _hiddenAyahs.clear();
      _selectedAyahs.clear();
    });
    _syncHiddenState();
  }

  /// Ordered list of ayah keys on this page (reading order: top→bottom, RTL).
  List<AyahKey> _orderedAyahKeys() {
    final glyphs = ref
        .read(glyphsForPageProvider((
          pageNumber: widget.pageNumber,
          riwayaId: widget.riwayaId,
          screenWidth: widget.imageNativeWidth.toDouble(),
          imageNativeWidth: widget.imageNativeWidth,
        )))
        .valueOrNull;
    if (glyphs == null) return [];
    // Deduplicate while preserving order.
    final seen = <AyahKey>{};
    return glyphs
        .map((g) => g.ayahKey)
        .where((k) => seen.add(k))
        .toList();
  }

  /// Reveal the first hidden ayah (in reading order).
  void _showNextAyah() {
    final ordered = _orderedAyahKeys();
    for (final key in ordered) {
      if (_hiddenAyahs.contains(key)) {
        setState(() => _hiddenAyahs.remove(key));
        _syncHiddenState();
        return;
      }
    }
  }

  /// Hide the first visible (non-hidden) ayah (in reading order).
  void _hideNextAyah() {
    final ordered = _orderedAyahKeys();
    for (final key in ordered) {
      if (!_hiddenAyahs.contains(key)) {
        setState(() => _hiddenAyahs.add(key));
        _syncHiddenState();
        return;
      }
    }
  }

  Widget _buildPageImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget image;
    if (_isBundledPage) {
      image = SizedBox.expand(
        child: Image.asset(_assetPath, fit: BoxFit.contain),
      );
    } else {
      final imageFile = File(_imagePath!);
      if (imageFile.existsSync() && imageFile.lengthSync() > 0) {
        image = SizedBox.expand(
          child: Image.file(imageFile, fit: BoxFit.contain),
        );
      } else {
        // Page not yet downloaded — show progress.
        return _DownloadingPagePlaceholder(
          pageNumber: widget.pageNumber,
          onAvailable: () {
            if (mounted) setState(() {});
          },
        );
      }
    }

    // In dark mode, invert the page colors (white bg → black, dark text → light).
    if (isDark) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          -1, 0, 0, 0, 255, //
          0, -1, 0, 0, 255, //
          0, 0, -1, 0, 255, //
          0, 0, 0, 1, 0, //
        ]),
        child: image,
      );
    }
    return image;
  }

  /// Compute the offset and scale for BoxFit.contain within the given box.
  /// Returns (offsetX, offsetY, scale).
  (double, double, double) _containFit(double boxW, double boxH) {
    const imgW = 1310.0; // native image width (King Fahd Complex)
    const imgH = 2032.0; // native image height
    final scaleW = boxW / imgW;
    final scaleH = boxH / imgH;
    final scale = scaleW < scaleH ? scaleW : scaleH;
    final renderedW = imgW * scale;
    final renderedH = imgH * scale;
    final offsetX = (boxW - renderedW) / 2;
    final offsetY = (boxH - renderedH) / 2;
    return (offsetX, offsetY, scale);
  }

  @override
  Widget build(BuildContext context) {
    if (!_pathReady) return const LoadingIndicator();

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxW = constraints.maxWidth;
        final boxH = constraints.maxHeight;
        final (offsetX, offsetY, scale) = _containFit(boxW, boxH);

        final nativeWidth = widget.imageNativeWidth;
        // scale = containFit scale. Glyphs are in native image coords,
        // so just multiply by scale to get screen coords, then add offset.
        final glyphScale = scale;

        final glyphsAsync = ref.watch(
          glyphsForPageProvider((
            pageNumber: widget.pageNumber,
            riwayaId: widget.riwayaId,
            screenWidth: nativeWidth.toDouble(),
            imageNativeWidth: nativeWidth,
          )),
        );

        // Watch bookmark to auto-highlight the bookmarked ayah.
        final bookmark = ref.watch(bookmarkNotifierProvider).valueOrNull;
        AyahKey? bookmarkedAyah;
        if (bookmark != null &&
            bookmark.pageNumber == widget.pageNumber &&
            bookmark.surahId != null &&
            bookmark.ayahNumber != null) {
          bookmarkedAyah = (bookmark.surahId!, bookmark.ayahNumber!);
        }

        // Watch for flash-highlight from navigation (search, juz, bookmark jump).
        final flashTarget = ref.watch(highlightAyahProvider);
        AyahKey? flashAyah;
        if (flashTarget != null) {
          // Only flash on THIS page if the ayah exists here.
          final hasAyah = glyphsAsync.valueOrNull?.any(
            (g) => g.surahId == flashTarget.$1 && g.ayahNumber == flashTarget.$2,
          ) ?? false;
          if (hasAyah) flashAyah = flashTarget;
        }

        // If page isn't available yet, show placeholder without glyphs.
        if (!_isBundledPage && _imagePath != null) {
          final f = File(_imagePath!);
          if (!f.existsSync() || f.lengthSync() == 0) {
            return _buildPageImage();
          }
        }

        return glyphsAsync.when(
          loading: () => _buildPageImage(),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (glyphs) {
            // Map raw glyph coords to screen space using exact x1,y1,x2,y2.
            final mapped = glyphs
                .map(
                  (g) => PageGlyph(
                    id: g.id,
                    pageNumber: g.pageNumber,
                    lineNumber: g.lineNumber,
                    surahId: g.surahId,
                    ayahNumber: g.ayahNumber,
                    position: g.position,
                    rect: Rect.fromLTRB(
                      g.rect.left * glyphScale + offsetX,
                      g.rect.top * glyphScale + offsetY,
                      g.rect.right * glyphScale + offsetX,
                      g.rect.bottom * glyphScale + offsetY,
                    ),
                  ),
                )
                .toList();

            return Stack(
              children: [
                // Bottom layer: catch taps on empty areas.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onBackgroundTap,
                  child: const SizedBox.expand(),
                ),
                // Highlight layer — BEHIND image (selected/bookmarked/flash).
                GlyphOverlay(
                  glyphs: mapped,
                  selectedAyahs: _selectedAyahs,
                  hiddenAyahs: const {},
                  bookmarkedAyah: bookmarkedAyah,
                  flashAyah: flashAyah,
                  onTap: _onAyahTap,
                  onLongPress: _onAyahLongPress,
                ),
                // Image layer.
                IgnorePointer(child: _buildPageImage()),
                // Hide layer — ON TOP of image (white covers text).
                if (_hiddenAyahs.isNotEmpty)
                  GlyphOverlay(
                    glyphs: mapped,
                    selectedAyahs: const {},
                    hiddenAyahs: _hiddenAyahs,
                    onTap: _onAyahTap,
                    onLongPress: _onAyahLongPress,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Shows download progress when a page isn't available yet.
/// Auto-refreshes when the page becomes available.
class _DownloadingPagePlaceholder extends ConsumerWidget {
  final int pageNumber;
  final VoidCallback onAvailable;

  const _DownloadingPagePlaceholder({
    required this.pageNumber,
    required this.onAvailable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dlState = ref.watch(pageDownloadProvider);

    // Check if our page has been downloaded since last check.
    if (dlState.lastDownloadedPage >= pageNumber) {
      // Schedule callback after build.
      WidgetsBinding.instance.addPostFrameCallback((_) => onAvailable());
    }

    final pagesRemaining = pageNumber - dlState.lastDownloadedPage;
    final hasError = dlState.error != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasError ? Icons.cloud_off : Icons.cloud_download_outlined,
              size: 48,
              color: hasError ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              hasError ? 'خطأ في التحميل' : 'جارٍ تحميل الصفحات...',
              style: const TextStyle(
                fontFamily: 'Noto Naskh Arabic',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (!hasError) ...[
              Text(
                'صفحة $pageNumber — ${pagesRemaining > 0 ? "بقي $pagesRemaining صفحة" : "جاهزة"}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: dlState.progress,
                  minHeight: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(dlState.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ] else ...[
              Text(
                dlState.error!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(pageDownloadProvider.notifier).retry(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
