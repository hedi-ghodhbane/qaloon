import 'package:flutter/material.dart';
import '../../core/models/page_glyph.dart';
import '../../shared/theme/colors.dart';

/// State for ayah interactions: selected (highlighted) and hidden.
typedef AyahKey = (int surahId, int ayahNumber);

class GlyphOverlay extends StatelessWidget {
  final List<PageGlyph> glyphs;
  final Set<AyahKey> selectedAyahs;
  final Set<AyahKey> hiddenAyahs;
  final ValueChanged<PageGlyph> onTap;
  final ValueChanged<PageGlyph> onLongPress;

  const GlyphOverlay({
    super.key,
    required this.glyphs,
    required this.selectedAyahs,
    required this.hiddenAyahs,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: glyphs.map((glyph) {
        final key = glyph.ayahKey;
        final isSelected = selectedAyahs.contains(key);
        final isHidden = hiddenAyahs.contains(key);

        return Positioned(
          left: glyph.rect.left,
          top: glyph.rect.top,
          width: glyph.rect.width,
          height: glyph.rect.height,
          child: GestureDetector(
            onTap: () => onTap(glyph),
            onLongPress: () => onLongPress(glyph),
            child: _AyahOverlayBox(
              isSelected: isSelected,
              isHidden: isHidden,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AyahOverlayBox extends StatelessWidget {
  final bool isSelected;
  final bool isHidden;

  const _AyahOverlayBox({
    required this.isSelected,
    required this.isHidden,
  });

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return const ColoredBox(color: AppColors.hiddenOverlay);
    }
    if (isSelected) {
      return const ColoredBox(color: AppColors.goldHighlight);
    }
    // Invisible tap region.
    return const SizedBox.shrink();
  }
}
