import 'package:flutter/material.dart';
import '../../core/models/page_glyph.dart';

/// State for ayah interactions: selected (highlighted) and hidden.
typedef AyahKey = (int surahId, int ayahNumber);

class GlyphOverlay extends StatelessWidget {
  final List<PageGlyph> glyphs;
  final Set<AyahKey> selectedAyahs;
  final Set<AyahKey> hiddenAyahs;
  final AyahKey? bookmarkedAyah;
  final ValueChanged<PageGlyph> onTap;
  final ValueChanged<PageGlyph> onLongPress;

  const GlyphOverlay({
    super.key,
    required this.glyphs,
    required this.selectedAyahs,
    required this.hiddenAyahs,
    this.bookmarkedAyah,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: glyphs.map((glyph) {
        final key = glyph.ayahKey;
        final isSelected = selectedAyahs.contains(key);
        final isHidden = hiddenAyahs.contains(key);
        final isBookmarked = bookmarkedAyah == key;

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
              isBookmarked: isBookmarked,
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
  final bool isBookmarked;

  const _AyahOverlayBox({
    required this.isSelected,
    required this.isHidden,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      // White to match scaffold — rendered on top of image to cover text.
      return const ColoredBox(color: Colors.white);
    }
    if (isBookmarked) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: Color(0x250D7377)),
      );
    }
    if (isSelected) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: Color(0x30CDA34F)),
      );
    }
    // Invisible but hit-testable tap region.
    return const SizedBox.expand();
  }
}
