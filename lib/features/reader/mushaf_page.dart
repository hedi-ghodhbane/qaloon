import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/models/page_glyph.dart';
import '../../core/providers/bookmark_provider.dart';
import '../../core/providers/reader_providers.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.isBundled) {
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

  /// Asset path for bundled riwaya pages.
  String get _assetPath =>
      'assets/pages/${widget.riwayaKey}_golden/${widget.pageNumber}.png';

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
    if (widget.isBundled) {
      return SizedBox.expand(
        child: Image.asset(_assetPath, fit: BoxFit.contain),
      );
    }
    final imageFile = File(_imagePath!);
    if (!imageFile.existsSync()) {
      return const Center(
        child: Text('صفحة غير متوفرة', style: TextStyle(fontSize: 18)),
      );
    }
    return SizedBox.expand(child: Image.file(imageFile, fit: BoxFit.contain));
  }

  /// Compute the offset and scale for BoxFit.contain within the given box.
  /// Returns (offsetX, offsetY, scale).
  (double, double, double) _containFit(double boxW, double boxH) {
    const imgW = 1260.0; // native image width (GoldenQuranRes)
    const imgH = 1969.0; // native image height
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

        return glyphsAsync.when(
          loading: () =>
              ColoredBox(color: Colors.white, child: _buildPageImage()),
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
                // Highlight layer — BEHIND image (selected/bookmarked).
                GlyphOverlay(
                  glyphs: mapped,
                  selectedAyahs: _selectedAyahs,
                  hiddenAyahs: const {},
                  bookmarkedAyah: bookmarkedAyah,
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
