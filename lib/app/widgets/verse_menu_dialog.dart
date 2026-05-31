import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/widgets/bookmark_category_picker_sheet.dart';

import 'package:my_quran/app/widgets/edit_note_dialog.dart';
import 'package:my_quran/app/widgets/verse_notes_sheet.dart';
import 'package:my_quran/quran/quran.dart';

import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/bookmark_service.dart';
import 'package:my_quran/app/services/notes_service.dart';
import 'package:my_quran/app/utils.dart';

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

  late final List<BookmarkCategory> categories = bookmarkService
      .getCategoriesSync();

  BookmarkCategory? currentCategory;

  // Notes state (verse-based)
  bool _notesLoading = true;
  List<VerseNote> _verseNotes = const [];

  bool get _hasNotes => _verseNotes.isNotEmpty;
  VerseNote? get _latestNote => _hasNotes ? _verseNotes.first : null;

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
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: ScaffoldMessenger(
        child: Builder(
          builder: (context) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 560 : 340,
                maxHeight: mq.size.height * (isLandscape ? 0.9 : 0.6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Scaffold(
                  backgroundColor: colorScheme.surface,
                  bottomNavigationBar: isLandscape
                      ? null
                      : _buildBottomActionsBar(context),
                  body: isLandscape
                      ? _buildLandscapeBody(context)
                      : _buildPortraitBody(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        Flexible(child: _buildVerseText(context, isLandscape: false)),
        if (!_notesLoading && _latestNote != null) _buildNotePreview(context),
      ],
    );
  }

  Widget _buildLandscapeBody(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildVerseText(context, isLandscape: true),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSideActionsColumn(context),
                        const SizedBox(height: 12),
                        if (!_notesLoading && _latestNote != null)
                          _buildNotePreview(context, maxLines: 5),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerseText(BuildContext context, {required bool isLandscape}) {
    final colorScheme = Theme.of(context).colorScheme;

    final maxFont = isLandscape ? 32.0 : 40.0;
    final height = isLandscape ? 1.8 : 2.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          widget.verse.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.fontSize.clamp(16, maxFont),
            height: height,
            fontFamily: widget.fontFamily.name,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionsBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.copy,
            label: s.copy,
            onTap: () => _copyVerse(context),
          ),
          _ActionButton(
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            iconColor: isBookmarked
                ? (currentCategory?.color ??
                      Theme.of(context).colorScheme.primary)
                : Theme.of(context).colorScheme.onSurfaceVariant,
            label: isBookmarked ? s.edit : s.bookmark,
            onTap: () => _openBookmarkPicker(context),
          ),
          _ActionButton(
            iconColor: _hasNotes
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            icon: _hasNotes ? Icons.edit_note : Icons.note_add_outlined,
            label: s.notes,
            onTap: () => _openNotes(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSideActionsColumn(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget action({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? iconColor,
    }) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor ?? colorScheme.onSurface),
        title: Text(label),
        onTap: onTap,
        dense: true,
      );
    }

    return Column(
      children: [
        action(
          icon: Icons.copy,
          label: isAr ? 'نسخ الآية' : 'Copy verse',
          onTap: () => _copyVerse(context),
        ),
        action(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          label: isBookmarked ? (isAr ? 'تعديل العلامة' : 'Edit bookmark') : (isAr ? 'إضافة علامة' : 'Add bookmark'),
          onTap: () => _openBookmarkPicker(context),
        ),
        action(
          icon: _hasNotes ? Icons.edit_note : Icons.note_add_outlined,
          iconColor: _hasNotes ? colorScheme.primary : null,
          label: s.notes,
          onTap: () => _openNotes(context),
        ),
      ],
    );
  }

  Widget _buildNotePreview(BuildContext context, {int maxLines = 2}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer.applyOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            right: isAr ? BorderSide(
              color: colorScheme.tertiary.applyOpacity(0.5),
              width: 3,
            ) : BorderSide.none,
            left: !isAr ? BorderSide(
              color: colorScheme.tertiary.applyOpacity(0.5),
              width: 3,
            ) : BorderSide.none,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _latestNote!.text,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBookmarkPicker(BuildContext context) async {
    final result = await showModalBottomSheet<BookmarkPickerResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false, // we already show a handle
      builder: (_) => BookmarkCategoryPickerSheet(
        categories: categories,
        isBookmarked: isBookmarked,
        currentCategoryId: bookmark?.categoryId,
      ),
    );

    if (result == null) return;

    if (result.action == BookmarkPickerAction.remove) {
      await _onRemoveBookmark(context);
      return;
    }

    final cat = result.category!;
    // If it's already selected, do nothing
    if (isBookmarked && bookmark?.categoryId == cat.id) return;

    await _onCategorySelected(context, cat);
  }
  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final surahName = isAr 
        ? Quran.instance.getSurahNameArabic(widget.surah) 
        : Quran.instance.getSurahName(widget.surah);
    final verseNum = isAr ? getArabicNumber(widget.verse.number) : widget.verse.number.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.menu_book,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              child: Row(
                children: [
                  Text(surahName),
                  const Text(' - '),
                  Text('${s.verse} '),
                  Text(
                    verseNum,
                    style: TextStyle(
                      fontFamily: isAr ? FontFamily.arabicNumbersFontFamily.name : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────

  Future<void> _onCategorySelected(
    BuildContext context,
    BookmarkCategory cat,
  ) async {
    if (isBookmarked) {
      final updated = bookmark!.copyWith(categoryId: () => cat.id);
      await bookmarkService.updateBookmark(updated);
      setState(() {
        bookmark = updated;
        _syncCategory();
      });
      if (context.mounted) {
        final msg = isAr ? 'تم النقل إلى "${cat.title}" ✓' : 'Moved to "${cat.title}" ✓';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } else {
      final newBookmark = VerseBookmark(
        id:
            '${widget.surah}_${widget.verse.number}_'
            '${DateTime.now().millisecondsSinceEpoch}',
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
      setState(() {
        isBookmarked = true;
        bookmark = newBookmark;
        _syncCategory();
      });

      if (context.mounted) {
        final msg = isAr ? 'تمت إضافة العلامة ✓' : 'Bookmark added ✓';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  Future<void> _onRemoveBookmark(BuildContext context) async {
    await bookmarkService.removeBookmarkByVerse(
      widget.surah,
      widget.verse.number,
    );
    setState(() {
      isBookmarked = false;
      bookmark = null;
      currentCategory = null;
    });
    if (context.mounted) {
      final msg = isAr ? 'تمت إزالة العلامة' : 'Bookmark removed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _openNotes(BuildContext context) async {
    if (_verseNotes.isEmpty) {
      // 0 notes: quick add
      final res = await showEditNoteDialog(context);
      if (res == null || res.action != NoteDialogAction.save) return;

      await notesService.addNote(
        surah: widget.surah,
        verse: widget.verse.number,
        text: res.text!,
      );

      await _loadNotes();
      return;
    }

    // 1+ notes: open manager sheet (add/edit/delete)
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
  }

  void _copyVerse(BuildContext context) {
    final surahName = isAr 
        ? Quran.instance.getSurahNameArabic(widget.surah) 
        : Quran.instance.getSurahName(widget.surah);
    final verseInPlainText = Quran.instance.getVerseInPlainText(
      widget.surah,
      widget.verse.number,
    );
    final verseNum = isAr ? getArabicNumber(widget.verse.number) : widget.verse.number.toString();
    
    final textToCopy = isAr 
        ? 'سورة $surahName - الآية {$verseNum}\n"$verseInPlainText"\n'
        : 'Surah $surahName - Verse $verseNum\n"$verseInPlainText"\n';
        
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(s.copiedToClipboard)));
  }
}

// ─────────────────────────────────────────────────────────
// Compact action button
// ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
