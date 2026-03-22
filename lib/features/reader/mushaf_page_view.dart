import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/providers/reader_providers.dart';
import 'mushaf_page.dart';

class MushafPageView extends ConsumerStatefulWidget {
  final int initialPage;
  final int riwayaId;
  final String riwayaKey;
  final int imageNativeWidth;
  final bool isBundled;
  final VoidCallback? onBackgroundTap;

  const MushafPageView({
    super.key,
    required this.initialPage,
    required this.riwayaId,
    required this.riwayaKey,
    required this.imageNativeWidth,
    this.isBundled = false,
    this.onBackgroundTap,
  });

  @override
  ConsumerState<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends ConsumerState<MushafPageView> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for external page changes (e.g. surah navigation).
    ref.listen<int>(currentPageProvider, (prev, next) {
      if (_controller.hasClients) {
        final currentIndex = _controller.page?.round() ?? 0;
        if (currentIndex != next - 1) {
          _controller.jumpToPage(next - 1);
        }
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: _controller,
        itemCount: kTotalPages,
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          ref.read(currentPageProvider.notifier).setPage(index + 1);
        },
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          return MushafPage(
            pageNumber: pageNumber,
            riwayaId: widget.riwayaId,
            riwayaKey: widget.riwayaKey,
            imageNativeWidth: widget.imageNativeWidth,
            isBundled: widget.isBundled,
            onBackgroundTap: widget.onBackgroundTap,
          );
        },
      ),
    );
  }
}
