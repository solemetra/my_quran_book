import 'package:flutter/material.dart';
import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/notes_service.dart';
import 'package:my_quran/app/utils.dart';
import 'package:my_quran/app/widgets/edit_note_dialog.dart';
import 'package:my_quran/quran/quran.dart';

class VerseNotesSheet extends StatefulWidget {
  const VerseNotesSheet({
    required this.surah,
    required this.verse,
    required this.onChanged,
    super.key,
  });

  final int surah;
  final int verse;
  final Future<void> Function() onChanged;

  @override
  State<VerseNotesSheet> createState() => VerseNotesSheetState();
}

class VerseNotesSheetState extends State<VerseNotesSheet> {
  final _notesService = NotesService();
  List<VerseNote> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await _notesService.getNotesForVerse(
      widget.surah,
      widget.verse,
    );
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _addNote() async {
    final res = await showEditNoteDialog(context);
    if (res == null) return;
    if (res.action == NoteDialogAction.save) {
      await _notesService.addNote(
        surah: widget.surah,
        verse: widget.verse,
        text: res.text!,
      );
      await _load();
      await widget.onChanged();
    }
  }

  Future<void> _editNote(VerseNote note) async {
    final res = await showEditNoteDialog(
      context,
      initialText: note.text,
      canDelete: true,
    );
    if (res == null) return;

    if (res.action == NoteDialogAction.delete) {
      await _notesService.removeNoteById(note.id);
    } else {
      await _notesService.updateNote(note.copyWith(text: res.text));
    }

    await _load();
    await widget.onChanged();
  }

  Future<void> _deleteNote(VerseNote note) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteNote),
        content: Text(s.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _notesService.removeNoteById(note.id);
      await _load();
      await widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final surahName = s.isAr
        ? Quran.instance.getSurahNameArabic(widget.surah)
        : Quran.instance.getSurahName(widget.surah);
    final verseNum = s.isAr
        ? getArabicNumber(widget.verse)
        : widget.verse.toString();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.notesVerseHeader(surahName, verseNum),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else ...[
              if (_notes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    s.noNotesYet,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _notes.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, i) {
                      final n = _notes[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(n.text),
                        subtitle: Text(
                          s.lastModifiedLabel(
                            '${n.updatedAt.year}/${n.updatedAt.month}/${n.updatedAt.day}',
                          ),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: s.edit,
                              onPressed: () => _editNote(n),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              tooltip: s.delete,
                              onPressed: () => _deleteNote(n),
                            ),
                          ],
                        ),
                        onTap: () => _editNote(n),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _addNote,
                  icon: const Icon(Icons.add),
                  label: Text(s.addNote),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
