import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/models/page_glyph.dart';
import '../../core/providers/reader_providers.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'glyph_overlay.dart';

class MushafPage extends ConsumerStatefulWidget {
  final int pageNumber;
  final int riwayaId;
  final String riwayaKey;
  final int imageNativeWidth;
  final bool isBundled;

  const MushafPage({
    super.key,
    required this.pageNumber,
    required this.riwayaId,
    required this.riwayaKey,
    required this.imageNativeWidth,
    this.isBundled = false,
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
      'assets/pages/${widget.riwayaKey}/${widget.pageNumber}.png';

  Future<void> _resolveImagePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/riwaya_${widget.riwayaKey}/${widget.pageNumber}.png';
    if (mounted) setState(() {
      _imagePath = path;
      _pathReady = true;
    });
  }

  void _onAyahTap(PageGlyph glyph) {
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
              title: const Text('حفظ علامة هنا'),
              onTap: () {
                Navigator.pop(ctx);
                // Bookmark handled by parent.
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

  Widget _buildPageImage(double screenWidth) {
    final Widget image;
    if (widget.isBundled) {
      image = Image.asset(
        _assetPath,
        fit: BoxFit.fitWidth,
        width: screenWidth,
        cacheWidth: screenWidth.toInt(),
      );
    } else {
      final imageFile = File(_imagePath!);
      if (!imageFile.existsSync()) {
        return const Center(
          child: Text('صفحة غير متوفرة', style: TextStyle(fontSize: 18)),
        );
      }
      image = Image.file(
        imageFile,
        fit: BoxFit.fitWidth,
        width: screenWidth,
        cacheWidth: screenWidth.toInt(),
      );
    }
    // White background so transparent PNG doesn't show the app bg color.
    return ColoredBox(color: Colors.white, child: image);
  }

  @override
  Widget build(BuildContext context) {
    if (!_pathReady) return const LoadingIndicator();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final glyphsAsync = ref.watch(
          glyphsForPageProvider((
            pageNumber: widget.pageNumber,
            riwayaId: widget.riwayaId,
            screenWidth: screenWidth,
            imageNativeWidth: widget.imageNativeWidth,
          )),
        );

        return glyphsAsync.when(
          loading: () => Center(
            child: Stack(children: [_buildPageImage(screenWidth)]),
          ),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (glyphs) {
            return Center(
              child: Stack(
                children: [
                  _buildPageImage(screenWidth),
                  GlyphOverlay(
                    glyphs: glyphs,
                    selectedAyahs: _selectedAyahs,
                    hiddenAyahs: _hiddenAyahs,
                    onTap: _onAyahTap,
                    onLongPress: _onAyahLongPress,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
