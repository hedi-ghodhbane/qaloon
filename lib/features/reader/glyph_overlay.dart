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
    // Find the last segment per ayah (where the marker ۝ sits).
    final lastSegment = <AyahKey, int>{};
    for (final g in glyphs) {
      final key = g.ayahKey;
      final prev = lastSegment[key];
      if (prev == null || g.position > prev) {
        lastSegment[key] = g.position;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: glyphs.map((glyph) {
        final key = glyph.ayahKey;
        final isSelected = selectedAyahs.contains(key);
        final isHidden = hiddenAyahs.contains(key);
        final isBookmarked = bookmarkedAyah == key;
        final isLastSegment = glyph.position == lastSegment[key];

        // Expand the rect vertically for hidden glyphs to cover tashkeel.
        const hideExpand = 6.0;
        final rect = isHidden
            ? Rect.fromLTRB(
                glyph.rect.left,
                glyph.rect.top - hideExpand,
                glyph.rect.right,
                glyph.rect.bottom + hideExpand,
              )
            : glyph.rect;

        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(glyph),
            onLongPress: () => onLongPress(glyph),
            child: _AyahOverlayBox(
              isSelected: isSelected,
              isHidden: isHidden,
              isBookmarked: isBookmarked,
              isLastSegment: isLastSegment,
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
  final bool isLastSegment;

  const _AyahOverlayBox({
    required this.isSelected,
    required this.isHidden,
    this.isBookmarked = false,
    this.isLastSegment = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      // Only trim the left edge on the last segment (where the marker ۝ sits).
      // The glyph rect ends at the marker's right edge. The marker is ~30px wide.
      // We pad left by 28px to expose just the marker, covering all text.
      if (isLastSegment) {
        return const Padding(
          padding: EdgeInsets.only(left: 28),
          child: ColoredBox(color: Colors.white),
        );
      }
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
