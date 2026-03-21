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

  const MushafPageView({
    super.key,
    required this.initialPage,
    required this.riwayaId,
    required this.riwayaKey,
    required this.imageNativeWidth,
    this.isBundled = false,
  });

  @override
  ConsumerState<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends ConsumerState<MushafPageView> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    // Pages are 1-indexed but PageView is 0-indexed.
    _controller = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void jumpToPage(int pageNumber) {
    _controller.jumpToPage(pageNumber - 1);
  }

  @override
  Widget build(BuildContext context) {
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
          );
        },
      ),
    );
  }
}
