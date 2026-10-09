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

  bool get _hasNotes => !_notesLoading && _verseNotes.isNotEmpty;

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
        insetPadding: const EdgeInsets.only(bottom: 28, left: 16, right: 16),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Md3SpringAppear(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Verse indicator badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$surahName • $verseNum',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontFamily: isAr
                                ? FontFamily.arabicNumbersFontFamily.name
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1.2,
                    height: 26,
                    color: colorScheme.outlineVariant.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),

                  // 2. Action: Copy
                  _SpringPillButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: colorScheme.onSurface,
                    ),
                    label: s.copy,
                    onTap: () => _copyVerse(context),
                  ),
                  const SizedBox(width: 6),

                  // 3. Action: Bookmark
                  _SpringPillButton(
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 19,
                      color: isBookmarked ? bookmarkColor : colorScheme.onSurface,
                    ),
                    label: s.bookmark,
                    backgroundColor: isBookmarked
                        ? bookmarkColor.withOpacity(0.16)
                        : null,
                    foregroundColor: isBookmarked ? bookmarkColor : null,
                    onTap: () => _openBookmarkPicker(context),
                  ),
                  const SizedBox(width: 6),

                  // 4. Action: Notes
                  _SpringPillButton(
                    icon: Icon(
                      _hasNotes
                          ? Icons.sticky_note_2_rounded
                          : Icons.edit_note_rounded,
                      size: _hasNotes ? 19 : 21,
                      color: _hasNotes
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    label: s.note,
                    backgroundColor: _hasNotes
                        ? colorScheme.primaryContainer.withOpacity(0.4)
                        : null,
                    foregroundColor: _hasNotes ? colorScheme.primary : null,
                    badgeCount: _hasNotes ? _verseNotes.length : null,
                    onTap: () => _openNotes(context),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1.2,
                    height: 26,
                    color: colorScheme.outlineVariant.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),

                  // 5. Action: Close
                  _SpringIconButton(
                    icon: Icons.close_rounded,
                    tooltip: s.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
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

// ─────────────────────────────────────────────────────────
// MD3 Spring Pill Button (Icon + Label with spring feedback)
// ─────────────────────────────────────────────────────────

class _SpringPillButton extends StatefulWidget {
  const _SpringPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.badgeCount,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final int? badgeCount;

  @override
  State<_SpringPillButton> createState() => _SpringPillButtonState();
}

class _SpringPillButtonState extends State<_SpringPillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bg = widget.backgroundColor ?? colorScheme.surfaceContainerLow;
    final fg = widget.foregroundColor ?? colorScheme.onSurface;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.badgeCount != null && widget.badgeCount! > 0)
                  Badge.count(
                    count: widget.badgeCount!,
                    backgroundColor: colorScheme.primary,
                    textColor: colorScheme.onPrimary,
                    child: widget.icon,
                  )
                else
                  widget.icon,
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// MD3 Spring Icon Button (Circular close with spring feedback)
// ─────────────────────────────────────────────────────────

class _SpringIconButton extends StatefulWidget {
  const _SpringIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_SpringIconButton> createState() => _SpringIconButtonState();
}

class _SpringIconButtonState extends State<_SpringIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Tooltip(
        message: widget.tooltip,
        child: Material(
          color: colorScheme.surfaceContainerLow,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(
                widget.icon,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
