import 'package:flutter/material.dart';
import 'package:my_quran/app/design_tokens.dart';
import '../l10n.dart';

enum NoteDialogAction { save, delete }

class NoteDialogResult {
  const NoteDialogResult(this.action, {this.text});
  final NoteDialogAction action;
  final String? text;
}

/// Modern M3 Adaptive note creation & editing dialog.
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
      final mq = MediaQuery.of(ctx);
      final isTablet = mq.size.shortestSide >= 600;
      final isLandscape = mq.orientation == Orientation.landscape;
      final dialogMaxWidth = isTablet ? (isLandscape ? 620.0 : 540.0) : 380.0;

      return Directionality(
        textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Center(
          child: Md3SpringAppear(
            child: Dialog(
              backgroundColor: colorScheme.surface,
              shape: AppShapes.shapeLarge,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: dialogMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                initialText.isEmpty
                                    ? Icons.note_add_outlined
                                    : Icons.edit_note_rounded,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                initialText.isEmpty ? s.addNote : s.note,
                                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                            ),
                            if (canDelete)
                              IconButton.outlined(
                                tooltip: s.delete,
                                onPressed: () => Navigator.pop(
                                  ctx,
                                  const NoteDialogResult(NoteDialogAction.delete),
                                ),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Input field
                        TextField(
                          controller: controller,
                          minLines: 5,
                          maxLines: 9,
                          autofocus: true,
                          style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                          decoration: InputDecoration(
                            hintText: s.writeNoteHint,
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHigh,
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(s.cancel),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: Text(s.save),
                              onPressed: () {
                                final text = controller.text.trim();
                                if (text.isEmpty) {
                                  // Empty text: cancel if creating, delete if editing
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
