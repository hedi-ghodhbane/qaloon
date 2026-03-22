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
    // Stack with no size — only Positioned children are hit-testable.
    // Taps between glyphs pass through to the image layer below.
    return Stack(
      clipBehavior: Clip.none,
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
            behavior: HitTestBehavior.opaque,
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
      return const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFF5F0E8)),
      );
    }
    if (isSelected) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x30CDA34F),
          border: Border.all(color: const Color(0x80CDA34F), width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    // Invisible but hit-testable tap region.
    return const SizedBox.expand();
  }
}
