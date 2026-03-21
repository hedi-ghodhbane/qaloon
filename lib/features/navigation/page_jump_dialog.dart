import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/providers/reader_providers.dart';

void showPageJumpDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('الانتقال إلى صفحة'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '1 - $kTotalPages',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final page = int.tryParse(controller.text);
            if (page != null && page >= 1 && page <= kTotalPages) {
              ref.read(currentPageProvider.notifier).setPage(page);
              Navigator.pop(ctx);
              context.go('/');
            }
          },
          child: const Text('انتقال'),
        ),
      ],
    ),
  );
}
