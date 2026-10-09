import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/notes_service.dart';
import 'package:my_quran/app/settings_controller.dart';
import 'package:my_quran/app/utils.dart';
import 'package:my_quran/app/design_tokens.dart';
import 'package:my_quran/app/widgets/edit_note_dialog.dart';
import 'package:my_quran/quran/quran.dart';
import 'package:my_quran/app/l10n.dart';

enum NotesSort { updatedDesc, updatedAsc, createdDesc, createdAsc }

class NotesScreen extends StatefulWidget {
  const NotesScreen({
    this.settingsController,
    this.onNavigateToPage,
    super.key,
  });

  final SettingsController? settingsController;
  final void Function({
    required int page,
    required int surah,
    required int verse,
  })? onNavigateToPage;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _notesService = NotesService();

  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  List<VerseNote> _all = [];

  String _query = '';
  int? _surahFilter; // null = all
  NotesSort _sort = NotesSort.updatedDesc;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      setState(() => _query = _searchController.text.trim());
    });
  }

  Future<void> _load() async {
    final notes = await _notesService.getAllNotes();
    if (!mounted) return;
    setState(() {
      _all = notes;
      _loading = false;
    });
  }

  List<VerseNote> get _filtered {
    Iterable<VerseNote> items = _all;

    if (_surahFilter != null) {
      items = items.where((n) => n.surah == _surahFilter);
    }

    if (_query.isNotEmpty) {
      final q = _query;
      items = items.where((n) => n.text.contains(q));
    }

    final list = items.toList();
    list.sort((a, b) {
      int cmpDate(DateTime x, DateTime y) => x.compareTo(y);

      switch (_sort) {
        case NotesSort.updatedDesc:
          return cmpDate(b.updatedAt, a.updatedAt);
        case NotesSort.updatedAsc:
          return cmpDate(a.updatedAt, b.updatedAt);
        case NotesSort.createdDesc:
          return cmpDate(b.createdAt, a.createdAt);
        case NotesSort.createdAsc:
          return cmpDate(a.createdAt, b.createdAt);
      }
    });

    return list;
  }

  Future<void> _edit(VerseNote note) async {
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
  }

  Future<void> _delete(VerseNote note) async {
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
    }
  }

  void _navigateToNote(VerseNote note) {
    final pageNumber = Quran.instance.getPageNumber(note.surah, note.verse);
    if (widget.onNavigateToPage != null) {
      Navigator.pop(context);
      widget.onNavigateToPage!(
        page: pageNumber,
        surah: note.surah,
        verse: note.verse,
      );
    }
  }

  String _sortLabel(NotesSort s, S strings) {
    return switch (s) {
      NotesSort.updatedDesc => strings.lastModifiedNewest,
      NotesSort.updatedAsc => strings.lastModifiedOldest,
      NotesSort.createdDesc => strings.dateCreatedNewest,
      NotesSort.createdAsc => strings.dateCreatedOldest,
    };
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? labelText,
    IconData? prefixIconData,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIconData != null ? Icon(prefixIconData) : null,
      labelText: labelText,
      border: const OutlineInputBorder(borderRadius: AppShapes.borderMedium),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final items = _filtered;

    return Directionality(
      textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.notes),
          actions: [
            PopupMenuButton<NotesSort>(
              tooltip: s.sortBy,
              initialValue: _sort,
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => NotesSort.values
                  .map(
                    (v) => PopupMenuItem(value: v, child: Text(_sortLabel(v, s))),
                  )
                  .toList(),
              icon: const Icon(Icons.sort),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : AdaptiveContent(
                child: Column(
                  children: [
                    _buildSearchAndFilter(s),
                    Expanded(
                      child: items.isEmpty
                          ? _buildEmptyState(s, colorScheme)
                          : _buildNotesList(items, s, colorScheme),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSearchAndFilter(S s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: _inputDecoration(
              prefixIconData: Icons.search,
              hintText: s.searchInNotesHint,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: DropdownButtonFormField<int?>(
            value: _surahFilter,
            decoration: _inputDecoration(labelText: s.filterBySurah),
            items: [
              DropdownMenuItem<int?>(child: Text(s.allSurahs)),
              for (int i = 1; i <= 114; i++)
                DropdownMenuItem<int?>(
                  value: i,
                  child: Text(
                    '${s.surahLabel} ${s.isAr ? Quran.instance.getSurahNameArabic(i) : Quran.instance.getSurahName(i)}',
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _surahFilter = v),
          ),
        ),
        if (_surahFilter != null)
          TextButton.icon(
            onPressed: () => setState(() {
              _surahFilter = null;
            }),
            icon: const Icon(Icons.filter_list_off_outlined),
            label: Text(s.clearFilter),
          ),
      ],
    );
  }

  Widget _buildEmptyState(S s, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Md3SpringAppear(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: AppShapes.borderLarge,
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.note_alt_outlined,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.noNotes,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(
    List<VerseNote> items,
    S s,
    ColorScheme colorScheme,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final n = items[i];
        final surahName = s.isAr
            ? Quran.instance.getSurahNameArabic(n.surah)
            : Quran.instance.getSurahName(n.surah);

        final verseNum = s.isAr
            ? getArabicNumber(n.verse)
            : n.verse.toString();
        final pageNumber = Quran.instance.getPageNumber(n.surah, n.verse);
        final pageNum = s.isAr
            ? getArabicNumber(pageNumber)
            : pageNumber.toString();
        final verseText = Quran.instance.getVerse(n.surah, n.verse);
        final previewVerse = verseText.length > 100
            ? '${verseText.substring(0, 100)}...'
            : verseText;
        final fontFamilyName = widget.settingsController?.fontFamily.name ??
            FontFamily.hafs.name;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppShapes.borderMedium,
            side: BorderSide(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: InkWell(
            borderRadius: AppShapes.borderMedium,
            onTap: () {
              if (widget.onNavigateToPage != null) {
                _navigateToNote(n);
              } else {
                _edit(n);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Surah & Verse info + edit button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s.surahLabel} $surahName',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${s.verse} $verseNum  •  ${s.page} $pageNum',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: s.isAr
                                        ? FontFamily
                                            .arabicNumbersFontFamily
                                            .name
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        tooltip: s.edit,
                        color: colorScheme.onSurfaceVariant,
                        onPressed: () => _edit(n),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: colorScheme.error,
                        ),
                        tooltip: s.delete,
                        onPressed: () => _delete(n),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Verse preview quote box
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        right: s.isAr
                            ? BorderSide(
                                color: colorScheme.primary,
                                width: 3.5,
                              )
                            : BorderSide.none,
                        left: !s.isAr
                            ? BorderSide(
                                color: colorScheme.primary,
                                width: 3.5,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      previewVerse,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.85,
                        color: colorScheme.onSurface,
                        fontFamily: fontFamilyName,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  // User note text
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          n.text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                height: 1.45,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
