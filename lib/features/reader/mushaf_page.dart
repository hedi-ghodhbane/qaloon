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
    debugPrint('[AYAH TAP] surah=${glyph.surahId}, ayah=${glyph.ayahNumber}, '
        'page=${glyph.pageNumber}, rect=${glyph.rect}');
    setState(() {
      final key = glyph.ayahKey;
      if (_hiddenAyahs.contains(key)) {
        _hiddenAyahs.remove(key);
        return;
      }
      if (_selectedAyahs.contains(key)) {
        _selectedAyahs.remove(key);
      } else {
        _selectedAyahs.add(key);
      }
    });
  }

  void _onAyahLongPress(PageGlyph glyph) {
    _showAyahActions(context, glyph);
  }

  void _showAyahActions(BuildContext context, PageGlyph glyph) {
    final key = glyph.ayahKey;
    final isHidden = _hiddenAyahs.contains(key);

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text('حفظ علامة — ${glyph.surahId}:${glyph.ayahNumber}'),
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(bookmarkNotifierProvider.notifier)
                    .setBookmark(
                      pageNumber: widget.pageNumber,
                      surahId: glyph.surahId,
                      ayahNumber: glyph.ayahNumber,
                      riwayaId: widget.riwayaId,
                    );
              },
            ),
            ListTile(
              leading: Icon(isHidden ? Icons.visibility : Icons.visibility_off),
              title: Text(isHidden ? 'إظهار الآية' : 'إخفاء الآية'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  if (isHidden) {
                    _hiddenAyahs.remove(key);
                  } else {
                    _hiddenAyahs.add(key);
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: const Text('إخفاء كل الصفحة'),
              onTap: () {
                Navigator.pop(ctx);
                _hideAllOnPage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _hideAllOnPage() {
    // Will be populated after glyphs load.
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
                // Highlight layer — BEHIND the image so highlights
                // only show through the opaque (text) areas of the
                // transparent PNG. Transparent areas stay clean.
                GlyphOverlay(
                  glyphs: mapped,
                  selectedAyahs: _selectedAyahs,
                  hiddenAyahs: _hiddenAyahs,
                  onTap: _onAyahTap,
                  onLongPress: _onAyahLongPress,
                ),
                // Image layer on top — transparent PNG lets highlights
                // bleed through text. IgnorePointer so taps reach glyphs below.
                IgnorePointer(child: _buildPageImage()),
              ],
            );
          },
        );
      },
    );
  }
}
