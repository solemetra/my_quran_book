import 'package:flutter/material.dart';
import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/pages/bookmark_categories_page.dart';
import 'package:my_quran/app/services/notes_service.dart';
import 'package:my_quran/app/settings_controller.dart';
import 'package:my_quran/app/widgets/edit_note_dialog.dart';
import 'package:my_quran/app/widgets/verse_notes_sheet.dart';

import 'package:my_quran/quran/quran.dart';

import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/bookmark_service.dart';
import 'package:my_quran/app/utils.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({
    required this.settingsController,
    required this.onNavigateToPage,
    super.key,
    this.onBookmarkChanged,
  });
  final void Function({
    required int page,
    required int surah,
    required int verse,
  })
  onNavigateToPage;
  final SettingsController settingsController;
  final VoidCallback? onBookmarkChanged;

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _bookmarkService = BookmarkService();

  List<VerseBookmark> _allBookmarks = [];
  List<BookmarkCategory> _categories = [];
  String? _selectedCategoryId; // null = show all
  bool _loading = true;
  final _notesService = NotesService();
  Map<String, List<VerseNote>> _notesByVerse = {};

  S get s => S(widget.settingsController.language);
  bool get isAr => widget.settingsController.language == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reload data and notify parent that bookmarks changed.
  Future<void> _reloadAndNotify() async {
    await _load();
    widget.onBookmarkChanged?.call();
  }

  Future<void> _load() async {
    final bookmarks = await _bookmarkService.getBookmarks();
    final categories = await _bookmarkService.getCategories();
    final notes = await _notesService.getAllNotes();

    // newest first
    bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final map = <String, List<VerseNote>>{};
    for (final n in notes) {
      final key = '${n.surah}:${n.verse}';
      (map[key] ??= []).add(n);
    }
    for (final e in map.entries) {
      e.value.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    setState(() {
      _allBookmarks = bookmarks;
      _categories = categories;
      _notesByVerse = map;
      _loading = false;
    });
  }

  List<VerseBookmark> get _filteredBookmarks {
    if (_selectedCategoryId == null) return _allBookmarks;
    return _allBookmarks
        .where((b) => b.categoryId == _selectedCategoryId)
        .toList();
  }

  BookmarkCategory? _getCategoryFor(VerseBookmark bookmark) {
    if (bookmark.categoryId == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == bookmark.categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filteredBookmarks;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(s.bookmarks),
              actions: [
                IconButton(
                  icon: const Icon(Icons.category_outlined),
                  tooltip: s.categories,
                  onPressed: _openCategoryManagement,
                ),
              ],
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // ── Category filter chips ──
                      _buildCategoryFilter(colorScheme),

                      // ── Bookmarks list ──
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  return _buildBookmarkCard(
                                    context,
                                    filtered[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Category filter bar
  // ─────────────────────────────────────────────

  Widget _buildCategoryFilter(ColorScheme colorScheme) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1, // +1 for "All"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" chip
            final isSelected = _selectedCategoryId == null;
            final count = _allBookmarks.length;
            final countText = isAr ? '($count)' : '($count)';
            return FilterChip(
              selected: isSelected,
              label: Text('${s.all} $countText'),
              avatar: isSelected
                  ? null
                  : Icon(
                      Icons.bookmarks_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              onSelected: (_) {
                setState(() => _selectedCategoryId = null);
              },
            );
          }

          final cat = _categories[index - 1];
          final isSelected = _selectedCategoryId == cat.id;
          final count = _allBookmarks
              .where((b) => b.categoryId == cat.id)
              .length;
          final countText = isAr ? '($count)' : '($count)';

          return FilterChip(
            selected: isSelected,
            label: Text('${s.bookmarkCategoryTitle(cat.id, cat.title)} $countText'),
            avatar: isSelected
                ? null
                : CircleAvatar(backgroundColor: cat.color, radius: 7),
            selectedColor: cat.color.applyOpacity(0.25),
            checkmarkColor: cat.color,
            onSelected: (_) {
              setState(() => _selectedCategoryId = cat.id);
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Empty state
  // ─────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isFiltered = _selectedCategoryId != null;
    return Builder(
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFiltered ? Icons.filter_list_off : Icons.bookmark_border,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.applyOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  isFiltered
                      ? s.noBookmarksInCategory
                      : s.noBookmarksYet,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? s.tryAnotherCategory
                      : s.addBookmarkHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.applyOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Bookmark card
  // ─────────────────────────────────────────────

  Widget _buildBookmarkCard(BuildContext context, VerseBookmark bookmark) {
    final colorScheme = Theme.of(context).colorScheme;
    final category = _getCategoryFor(bookmark);
    final surahName = isAr 
        ? Quran.instance.getSurahNameArabic(bookmark.surah) 
        : Quran.instance.getSurahName(bookmark.surah);
    final verseText = Quran.instance.getVerse(bookmark.surah, bookmark.verse);

    final verseNum = isAr ? getArabicNumber(bookmark.verse) : bookmark.verse.toString();
    final pageNum = isAr ? getArabicNumber(bookmark.pageNumber) : bookmark.pageNumber.toString();

    // Truncate verse text for preview
    final previewText = verseText.length > 100
        ? '${verseText.substring(0, 100)}...'
        : verseText;
    final verseKey = '${bookmark.surah}:${bookmark.verse}';
    final verseNotes = _notesByVerse[verseKey] ?? const [];
    final notesCount = verseNotes.length;
    final latestPreview = notesCount > 0 ? verseNotes.first.text : null;
    return Dismissible(
      key: Key(bookmark.id),
      direction: isAr ? DismissDirection.endToStart : DismissDirection.startToEnd,
      confirmDismiss: (_) => _deleteBookmark(bookmark),
      background: Container(
        alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
        padding: isAr ? const EdgeInsets.only(left: 24) : const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onBookmarkTap(bookmark),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: surah info + category badge ──
                Row(
                  children: [
                    // Category color indicator
                    if (category != null)
                      Container(
                        width: 4,
                        height: 36,
                        margin: isAr ? const EdgeInsets.only(left: 10) : const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                    // Surah + verse info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.surahLabel} $surahName',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${s.verse} $verseNum  •  '
                            '${s.page} $pageNum',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontFamily: isAr ?
                                      FontFamily.arabicNumbersFontFamily.name : null,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Category chip
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.color.applyOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.bookmarkCategoryTitle(category.id, category.title),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: category.color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),

                    // More options
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'change_category',
                          child: Row(
                            children: [
                              const Icon(Icons.category_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(s.changeCategory),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'notes',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_note_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(s.notes),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                s.delete,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) => _onMenuAction(value, bookmark),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Verse preview ──
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: (category?.color ?? colorScheme.primary)
                        .applyOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      right: isAr
                          ? BorderSide(
                              color: category?.color ?? colorScheme.primary,
                              width: 3.5,
                            )
                          : BorderSide.none,
                      left: !isAr
                          ? BorderSide(
                              color: category?.color ?? colorScheme.primary,
                              width: 3.5,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    previewText,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.85,
                      color: colorScheme.onSurface,
                      fontFamily: widget.settingsController.fontFamily.name,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),

                // ── Note ──
                const SizedBox(height: 3),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: notesCount > 0 ? 3 : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_note_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notesCount == 0
                              ? s.noNotes
                              : '${s.notes}: ${isAr ? getArabicNumber(notesCount) : notesCount}'
                                    '${latestPreview != null ? ' • ${latestPreview.replaceAll('\n', ' ')}' : ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _openNotesForVerse(bookmark.surah, bookmark.verse),

                        child: Text(notesCount == 0 ? s.add : s.view),
                      ),
                    ],
                  ),
                ),

                // ── Date ──
                const SizedBox(height: 8),
                Align(
                  alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                  child: Text(
                    _formatDate(bookmark.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.applyOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────

  void _onBookmarkTap(VerseBookmark bookmark) {
    Navigator.pop(context);
    widget.onNavigateToPage(
      page: bookmark.pageNumber,
      surah: bookmark.surah,
      verse: bookmark.verse,
    );
  }

  void _onMenuAction(String action, VerseBookmark bookmark) {
    switch (action) {
      case 'notes':
        _openNotesSheet(bookmark.surah, bookmark.verse);
      case 'change_category':
        _changeCategory(bookmark);
      case 'delete':
        _deleteBookmark(bookmark);
    }
  }

  Future<void> _openNotesForVerse(int surah, int verse) async {
    final key = '$surah:$verse';
    final notes = _notesByVerse[key] ?? const <VerseNote>[];

    if (notes.isEmpty) {
      await _quickAddNote(surah, verse); // 1 tap add
      return;
    }

    await _openNotesSheet(surah, verse); // manage + add more notes
  }

  Future<void> _openNotesSheet(int surah, int verse) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: VerseNotesSheet(
            surah: surah,
            verse: verse,
            onChanged: _reloadAndNotify, // refresh cache + notify parent
          ),
        );
      },
    );
  }

  Future<void> _quickAddNote(int surah, int verse) async {
    final res = await showEditNoteDialog(context); // your new dialog API
    if (res == null || res.action != NoteDialogAction.save) return;

    await _notesService.addNote(surah: surah, verse: verse, text: res.text!);

    await _reloadAndNotify(); // reload bookmarks + notes map
  }

  Future<void> _changeCategory(VerseBookmark bookmark) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text(s.changeCategory),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat.id == bookmark.categoryId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.color,
                      radius: 14,
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    title: Text(s.bookmarkCategoryTitle(cat.id, cat.title)),
                    selected: isSelected,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () => Navigator.pop(context, cat.id),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(s.cancel),
              ),
            ],
          ),
        );
      },
    );

    if (result == null || result == bookmark.categoryId) return;

    final updated = bookmark.copyWith(categoryId: () => result);
    await _bookmarkService.updateBookmark(updated);
    await _reloadAndNotify();

    if (mounted) {
      final msg = s.categoryChanged;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<bool?> _deleteBookmark(VerseBookmark bookmark) async {
    final confirmed = await _confirmDelete(context, bookmark);
    if (confirmed ?? false) {
      await _bookmarkService.removeBookmarkById(bookmark.id);
      await _reloadAndNotify();
      if (mounted) {
        final msg = s.bookmarkRemoved;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
    return confirmed ?? false;
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    VerseBookmark bookmark,
  ) async {
    final surahName = isAr 
        ? Quran.instance.getSurahNameArabic(bookmark.surah) 
        : Quran.instance.getSurahName(bookmark.surah);
    final verseNum = isAr ? getArabicNumber(bookmark.verse) : bookmark.verse.toString();
    
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(s.deleteBookmark),
          content: Text(
            s.deleteBookmarkConfirm(surahName, verseNum),
            style: TextStyle(
              fontSize: 16,
              fontFamily: isAr ? FontFamily.arabicNumbersFontFamily.name : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.delete),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategoryManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ManageCategoriesScreen()),
    );
    // Reload in case categories changed
    await _reloadAndNotify();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (isAr) {
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
      if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    } else {
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    }

    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
