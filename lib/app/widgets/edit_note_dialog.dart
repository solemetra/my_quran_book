import 'package:flutter/material.dart';

import '../l10n.dart';

enum NoteDialogAction { save, delete }

class NoteDialogResult {
  const NoteDialogResult(this.action, {this.text});
  final NoteDialogAction action;
  final String? text;
}

/// - If user cancels => returns null
/// - If user saves => returns NoteDialogResult(save, text: ...)
/// - If user deletes (only if canDelete) => returns NoteDialogResult(delete)
Future<NoteDialogResult?> showEditNoteDialog(
  BuildContext context, {
  String initialText = '',
  bool canDelete = false,
}) async {
  final controller = TextEditingController(text: initialText);

  return showDialog<NoteDialogResult>(
    context: context,
    builder: (ctx) {
      final s = S.of(ctx);
      final colorScheme = Theme.of(ctx).colorScheme;

      return Directionality(
        textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.note),
              if (canDelete)
                TextButton(
                  onPressed: () => Navigator.pop(
                    ctx,
                    const NoteDialogResult(NoteDialogAction.delete),
                  ),
                  child: Text(
                    s.delete,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
            ],
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: s.writeNoteHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  // treat empty as cancel for new note, or delete for existing
                  if (canDelete) {
                    Navigator.pop(
                      ctx,
                      const NoteDialogResult(NoteDialogAction.delete),
                    );
                  } else {
                    Navigator.pop(ctx);
                  }
                  return;
                }
                Navigator.pop(
                  ctx,
                  NoteDialogResult(NoteDialogAction.save, text: text),
                );
              },
              child: Text(s.save),
            ),
          ],
        ),
      );
    },
  );
}
