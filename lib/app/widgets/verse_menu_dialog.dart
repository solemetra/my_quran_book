import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_quran/app/design_tokens.dart';
import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/bookmark_service.dart';
import 'package:my_quran/app/services/notes_service.dart';
import 'package:my_quran/app/utils.dart';
import 'package:my_quran/app/widgets/bookmark_category_picker_sheet.dart';
import 'package:my_quran/app/widgets/edit_note_dialog.dart';
import 'package:my_quran/app/widgets/verse_notes_sheet.dart';
import 'package:my_quran/quran/quran.dart';

class VerseMenuDialog extends StatefulWidget {
  const VerseMenuDialog({
    required this.fontFamily,
    required this.surah,
    required this.verse,
    required this.fontSize,
    required this.language,
    super.key,
  });

  final int surah;
  final Verse verse;
  final FontFamily fontFamily;
  final double fontSize;
  final String language;

  @override
  State<VerseMenuDialog> createState() => _VerseMenuDialogState();
}

class _VerseMenuDialogState extends State<VerseMenuDialog> {
  late final bookmarkService = BookmarkService();
  late final notesService = NotesService();

  late bool isBookmarked = bookmarkService.isBookmarked(
    widget.surah,
    widget.verse.number,
  );

  late VerseBookmark? bookmark = bookmarkService.getBookmarkFor(
    widget.surah,
    widget.verse.number,
  );

  late final List<BookmarkCategory> categories =
      bookmarkService.getCategoriesSync();

  BookmarkCategory? currentCategory;

  bool _notesLoading = true;
  List<VerseNote> _verseNotes = const [];

  bool get _hasNotes => _verseNotes.isNotEmpty;

  S get s => S(widget.language);
  bool get isAr => widget.language == 'ar';

  @override
  void initState() {
    super.initState();
    _syncCategory();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await notesService.getNotesForVerse(
      widget.surah,
      widget.verse.number,
    );
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (!mounted) return;
    setState(() {
      _verseNotes = notes;
      _notesLoading = false;
    });
  }

  void _syncCategory() {
    if (isBookmarked && bookmark?.categoryId != null) {
      try {
        currentCategory = categories.firstWhere(
          (c) => c.id == bookmark!.categoryId,
        );
      } catch (_) {
        currentCategory = null;
      }
    } else {
      currentCategory = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final surahName = isAr
        ? Quran.instance.getSurahNameArabic(widget.surah)
        : Quran.instance.getSurahName(widget.surah);
    final verseNum = isAr
        ? getArabicNumber(widget.verse.number)
        : widget.verse.number.toString();

    final bookmarkColor = isBookmarked
        ? (currentCategory?.color ?? colorScheme.primary)
        : colorScheme.onSurfaceVariant;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        alignment: Alignment.bottomCenter,
        insetPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Md3SpringAppear(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Verse indicator badge
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '$surahName • $verseNum',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontFamily: isAr
                                  ? FontFamily.arabicNumbersFontFamily.name
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 1,
                  height: 24,
                  color: colorScheme.outlineVariant.withOpacity(0.6),
                ),
                const SizedBox(width: 4),

                // 2. Action: Copy
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  tooltip: s.copyVerse,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _copyVerse(context),
                ),

                // 3. Action: Bookmark
                Tooltip(
                  message: isBookmarked ? s.editBookmark : s.addBookmark,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _toggleBookmark(context),
                      onLongPress: () => _openBookmarkPicker(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 22,
                          color: bookmarkColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Action: Notes
                Tooltip(
                  message: s.notes,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _openNotes(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Badge(
                          isLabelVisible: !_notesLoading && _hasNotes,
                          label: Text('${_verseNotes.length}'),
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                          child: Icon(
                            _hasNotes
                                ? Icons.sticky_note_2_rounded
                                : Icons.edit_note_rounded,
                            size: 22,
                            color: _hasNotes
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 5. Action: Close
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: s.close,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyVerse(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final surahName = isAr
        ? Quran.instance.getSurahNameArabic(widget.surah)
        : Quran.instance.getSurahName(widget.surah);
    final verseInPlainText = Quran.instance.getVerseInPlainText(
      widget.surah,
      widget.verse.number,
    );
    final verseNum = isAr
        ? getArabicNumber(widget.verse.number)
        : widget.verse.number.toString();

    final textToCopy = isAr
        ? '${s.surahLabel} $surahName - ${s.verse} {$verseNum}\n"$verseInPlainText"\n'
        : '${s.surahLabel} $surahName - ${s.verse} $verseNum\n"$verseInPlainText"\n';

    Clipboard.setData(ClipboardData(text: textToCopy));
    Navigator.of(context).pop();

    messenger.showSnackBar(
      SnackBar(
        content: Text(s.copiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleBookmark(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!isBookmarked) {
      BookmarkCategory cat;
      try {
        cat = categories.firstWhere((c) => c.id == 'cat-reading');
      } catch (_) {
        cat = categories.isNotEmpty
            ? categories.first
            : const BookmarkCategory(
                id: 'cat-reading',
                title: 'Чтение',
                color: Color(0xFF2E7D32),
              );
      }

      final newBookmark = VerseBookmark(
        id: '${widget.surah}_${widget.verse.number}_${DateTime.now().millisecondsSinceEpoch}',
        surah: widget.surah,
        verse: widget.verse.number,
        pageNumber: Quran.instance.getPageNumber(
          widget.surah,
          widget.verse.number,
        ),
        createdAt: DateTime.now(),
        categoryId: cat.id,
      );

      await bookmarkService.addBookmark(newBookmark);
      if (!mounted) return;
      setState(() {
        isBookmarked = true;
        bookmark = newBookmark;
        _syncCategory();
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(s.bookmarkAdded),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      await bookmarkService.removeBookmarkByVerse(
        widget.surah,
        widget.verse.number,
      );
      if (!mounted) return;
      setState(() {
        isBookmarked = false;
        bookmark = null;
        currentCategory = null;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(s.bookmarkRemoved),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openBookmarkPicker(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showModalBottomSheet<BookmarkPickerResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => BookmarkCategoryPickerSheet(
        categories: categories,
        isBookmarked: isBookmarked,
        currentCategoryId: bookmark?.categoryId,
      ),
    );

    if (result == null || !mounted) return;

    if (result.action == BookmarkPickerAction.remove) {
      await bookmarkService.removeBookmarkByVerse(
        widget.surah,
        widget.verse.number,
      );
      if (!mounted) return;
      setState(() {
        isBookmarked = false;
        bookmark = null;
        currentCategory = null;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.bookmarkRemoved),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final cat = result.category!;
    if (isBookmarked && bookmark?.categoryId == cat.id) return;

    if (isBookmarked) {
      final updated = bookmark!.copyWith(categoryId: () => cat.id);
      await bookmarkService.updateBookmark(updated);
      if (!mounted) return;
      setState(() {
        bookmark = updated;
        _syncCategory();
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.movedTo(s.bookmarkCategoryTitle(cat.id, cat.title))),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final newBookmark = VerseBookmark(
        id: '${widget.surah}_${widget.verse.number}_${DateTime.now().millisecondsSinceEpoch}',
        surah: widget.surah,
        verse: widget.verse.number,
        pageNumber: Quran.instance.getPageNumber(
          widget.surah,
          widget.verse.number,
        ),
        createdAt: DateTime.now(),
        categoryId: cat.id,
      );
      await bookmarkService.addBookmark(newBookmark);
      if (!mounted) return;
      setState(() {
        isBookmarked = true;
        bookmark = newBookmark;
        _syncCategory();
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.bookmarkAdded),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openNotes(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    if (_verseNotes.isEmpty) {
      final res = await showEditNoteDialog(context);
      if (res == null || res.action != NoteDialogAction.save || !mounted) return;

      await notesService.addNote(
        surah: widget.surah,
        verse: widget.verse.number,
        text: res.text!,
      );

      await _loadNotes();
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.save),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: VerseNotesSheet(
          surah: widget.surah,
          verse: widget.verse.number,
          onChanged: _loadNotes,
        ),
      ),
    );
    if (mounted) {
      await _loadNotes();
    }
  }
}
