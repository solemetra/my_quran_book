import 'package:flutter/material.dart';

import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/bookmark_service.dart';
import 'package:my_quran/app/l10n.dart';
import 'package:my_quran/app/design_tokens.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _bookmarkService = BookmarkService();
  List<BookmarkCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await _bookmarkService.getCategories();
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Directionality(
      textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(s.manageCategories)),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addCategory(s),
          child: const Icon(Icons.add),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
            ? Center(child: Text(s.noCategories))
            : AdaptiveContent(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isDefault = cat.id == 'default';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.color,
                      radius: 16,
                    ),
                    title: Text(s.bookmarkCategoryTitle(cat.id, cat.title)),
                    subtitle: isDefault
                        ? Text(s.defaultCategory)
                        : null,
                    trailing: isDefault
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editCategory(cat, s),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () => _deleteCategory(cat, s),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
      ),
    );
  }

  Future<void> _addCategory(S s) async {
    final titleController = TextEditingController();
    const Color selectedColor = Colors.blue;

    final result = await showDialog<BookmarkCategory>(
      context: context,
      builder: (ctx) => _CategoryFormDialog(
        title: s.newCategory,
        titleController: titleController,
        initialColor: selectedColor,
        actionLabel: s.create,
      ),
    );

    if (result != null) {
      await _bookmarkService.addCategory(result);
      await _load();
    }
  }

  Future<void> _editCategory(BookmarkCategory cat, S s) async {
    final titleController = TextEditingController(text: cat.title);

    final result = await showDialog<BookmarkCategory>(
      context: context,
      builder: (ctx) => _CategoryFormDialog(
        title: s.editCategory,
        titleController: titleController,
        initialColor: cat.color,
        existingId: cat.id,
        actionLabel: s.save,
      ),
    );

    if (result != null) {
      await _bookmarkService.updateCategory(result);
      await _load();
    }
  }

  Future<void> _deleteCategory(BookmarkCategory cat, S s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(s.deleteCategory),
          content: Text(
            s.deleteCategoryConfirm(
              s.bookmarkCategoryTitle(cat.id, cat.title),
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

    if (confirmed ?? false) {
      await _bookmarkService.removeCategory(cat.id);
      await _load();
    }
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({
    required this.title,
    required this.titleController,
    required this.initialColor,
    required this.actionLabel,
    this.existingId,
  });

  final String title;
  final TextEditingController titleController;
  final Color initialColor;
  final String actionLabel;
  final String? existingId;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late Color _selectedColor;

  static const List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
    Colors.lime,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Directionality(
      textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: AlertDialog(
        title: Text(widget.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: widget.titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: s.categoryName,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(s.color),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              final title = widget.titleController.text.trim();
              if (title.isEmpty) return;
              final cat = BookmarkCategory(
                id:
                    widget.existingId ??
                    'cat_${DateTime.now().millisecondsSinceEpoch}',
                title: title,
                color: _selectedColor,
              );
              Navigator.pop(context, cat);
            },
            child: Text(widget.actionLabel),
          ),
        ],
      ),
    );
  }
}
