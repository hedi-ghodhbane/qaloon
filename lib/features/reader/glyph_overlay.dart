import 'package:flutter/material.dart';
import '../../core/models/page_glyph.dart';

/// State for ayah interactions: selected (highlighted) and hidden.
typedef AyahKey = (int surahId, int ayahNumber);

class GlyphOverlay extends StatelessWidget {
  final List<PageGlyph> glyphs;
  final Set<AyahKey> selectedAyahs;
  final Set<AyahKey> hiddenAyahs;
  final AyahKey? bookmarkedAyah;
  final AyahKey? flashAyah;
  final ValueChanged<PageGlyph> onTap;
  final ValueChanged<PageGlyph> onLongPress;

  const GlyphOverlay({
    super.key,
    required this.glyphs,
    required this.selectedAyahs,
    required this.hiddenAyahs,
    this.bookmarkedAyah,
    this.flashAyah,
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
        final isFlashing = flashAyah == key;
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
            child: isFlashing
                ? _FlashingOverlay()
                : _AyahOverlayBox(
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
      final hideColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white;
      return ColoredBox(color: hideColor);
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

/// A pulsing highlight overlay that fades in and out 3 times over ~3 seconds.
class _FlashingOverlay extends StatefulWidget {
  @override
  State<_FlashingOverlay> createState() => _FlashingOverlayState();
}

class _FlashingOverlayState extends State<_FlashingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  int _pulseCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(begin: 0.0, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseCount++;
        if (_pulseCount < 3) {
          _controller.forward();
        }
        // After 3 pulses, widget stays invisible — provider clears it.
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0D7377),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
