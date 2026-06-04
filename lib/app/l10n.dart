import 'package:flutter/material.dart';

class S {
  final String lang;
  S(this.lang);

  bool get isAr => lang == 'ar';

  // Navigation Sheet
  String get page => isAr ? 'الصفحة' : 'Page';
  String get surah => isAr ? 'السورة' : 'Surah';
  String get juz => isAr ? 'الجزء' : 'Juz';
  String get verse => isAr ? 'الآية' : 'Verse';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';
  String get navigate => isAr ? 'انتقال' : 'Go to';

  // Settings
  String get settings => isAr ? 'الإعدادات' : 'Settings';
  String get font => isAr ? 'الخط' : 'Font';
  String get fontSize => isAr ? 'حجم الخط' : 'Font Size';
  String get fontWeight => isAr ? 'سماكة الخط' : 'Font Weight';
  String get fontWeightNormal => isAr ? 'عادي' : 'Normal';
  String get fontWeightBold => isAr ? 'عريض' : 'Bold';
  String get fontType => isAr ? 'نوع الخط' : 'Font Type';
  String get fontTypeUthmani => isAr ? 'الرسم العثماني' : 'Uthmanic';
  String get fontTypeMadina => isAr ? 'خط المدينة' : 'Madina';
  String get reading => isAr ? 'القراءة' : 'Reading';
  String get lineHeight => isAr ? 'ارتفاع الأسطر' : 'Line Height';
  String get lineHeightAuto => isAr ? 'تلقائي' : 'Auto';
  String get textAlign => isAr ? 'محاذاة النص' : 'Text Align';
  String get textAlignJustify => isAr ? 'متساوي' : 'Justify';
  String get textAlignCenter => isAr ? 'وسط' : 'Center';
  String get textAlignStart => isAr ? 'يمين' : 'Left';
  String get narration => isAr ? 'الرواية' : 'Narration';
  String get narrationHafs => isAr ? 'حفص عن عاصم' : 'Hafs';
  String get narrationWarsh => isAr ? 'ورش عن نافع' : 'Warsh';
  String get appearance => isAr ? 'المظهر' : 'Appearance';
  String get themeDefault => isAr ? 'الافتراضي' : 'Default';
  String get themeMyQuran => isAr ? 'قرآني' : 'My Quran';
  String get themeMyQuranDesc =>
      isAr
          ? 'المظهر الافتراضي الخاص بتطبيق "قرآني"'
          : 'The default theme for My Quran';
  String get themeDynamic => isAr ? 'ألوان الجهاز' : 'Dynamic';
  String get themeDynamicDesc => isAr ? 'يستخدم ألوان جهازك الشخصية مع التبديل التلقائي' : 'Uses your system colors with auto-switching';
  String get themeSepia => isAr ? 'سيبيا' : 'Sepia';
  String get themeSepiaDesc => isAr ? 'ألوان مشابهة للورق، مريحة للعين' : 'Paper-like colors, easy on the eyes';
  String get trueBlack => isAr ? 'خلفية سوداء للوضع الداكن' : 'True Black (AMOLED)';
  String get trueBlackDesc => isAr ? 'خلفية سوداء تماماً لشاشات AMOLED' : 'Pure black background for dark mode';
  String get general => isAr ? 'عام' : 'General';
  String get bookMode => isAr ? 'وضع الكتاب' : 'Book Mode';
  String get bookModeDesc => isAr ? 'تقليب الصفحات بالسحب يميناً ويساراً' : 'Swipe horizontally to change pages';
  String get verticalScroll => isAr ? 'تمرير عمودي' : 'Vertical Scroll';
  String get keepScreenOn => isAr ? 'إبقاء الشاشة مضاءة' : 'Keep Screen On';
  String get keepScreenOnDesc => isAr ? 'منع انطفاء الشاشة أثناء القراءة' : 'Prevent screen from turning off';
  String get showHizbNumber => isAr ? 'عرض رقم الحزب' : 'Show Hizb Number';
  String get showHizbNumberDesc => isAr ? 'يظهر رقم الحزب بدلاً من رقم الجزء' : 'Show Hizb number instead of Juz';
  String get hideQuarterNumber => isAr ? 'إخفاء رقم الربع' : 'Hide Quarter Number';
  String get language => isAr ? 'اللغة' : 'Language';
  String get langAr => isAr ? 'العربية' : 'Arabic';
  String get langEn => isAr ? 'English' : 'English';
  String get backup => isAr ? 'النسخ الاحتياطي' : 'Backup';
  String get backupDesc => isAr ? 'تصدير/استيراد العلامات والملاحظات' : 'Import/Export Bookmarks & Notes';
  String get exportBackup => isAr ? 'تصدير نسخة احتياطية' : 'Export Backup';
  String get exportBackupDesc => isAr ? 'مشاركة ملف النسخة أو حفظه' : 'Share or save the backup file';
  String get importBackup => isAr ? 'استيراد نسخة احتياطية' : 'Import Backup';
  String get importBackupDesc => isAr ? 'دمج مع البيانات الحالية أو استبدالها' : 'Merge or replace current data';
  String get backupDate => isAr ? 'التاريخ' : 'Date';
  String get backupCategories => isAr ? 'التصنيفات' : 'Categories';
  String get backupBookmarks => isAr ? 'العلامات' : 'Bookmarks';
  String get backupNotes => isAr ? 'الملاحظات' : 'Notes';
  String get chooseImportMode => isAr ? 'اختر طريقة الاستيراد:' : 'Choose import mode:';
  String get merge => isAr ? 'دمج' : 'Merge';
  String get replace => isAr ? 'استبدال' : 'Replace';
  String get importSuccess => isAr ? 'تم الاستيراد بنجاح' : 'Imported successfully';
  String get importError => isAr ? 'فشل الاستيراد' : 'Import failed';
  String get success => isAr ? 'تم بنجاح' : 'Success';
  String get error => isAr ? 'خطأ' : 'Error';
  String get save => isAr ? 'حفظ' : 'Save';

  // Search
  String get searchHint => isAr ? 'ابحث عن آية...' : 'Search for a verse...';
  String get noResults => isAr ? 'لا توجد نتائج' : 'No results found';
  String get resultsCount => isAr ? 'عدد النتائج' : 'Results';
  String showingNofM(int n, int m) => isAr ? 'عرض $n من $m' : 'Showing $n of $m';
  String resultsCountN(int n) => isAr ? 'عدد النتائج: $n' : 'Total results: $n';
  String get matchExact => isAr ? 'مطابق' : 'Exact';
  String get matchPrefix => isAr ? 'بداية' : 'Prefix';
  String get matchContains => isAr ? 'داخل' : 'Contains';
  String get matchFlexible => isAr ? 'مرن' : 'Flexible';
  String get matchAllWords => isAr ? 'جميع الكلمات' : 'All words';
  String get matchAnyWord => isAr ? 'أي كلمة' : 'Any word';
  String get matchLabel => isAr ? 'مطابقة' : 'Match';

  // Verse Menu
  String get copy => isAr ? 'نسخ' : 'Copy';
  String get copyVerse => isAr ? 'نسخ الآية' : 'Copy verse';
  String get bookmark => isAr ? 'علامة' : 'Bookmark';
  String get bookmarkAdded => isAr ? 'تمت إضافة العلامة ✓' : 'Bookmark added ✓';
  String get bookmarkRemoved => isAr ? 'تمت إزالة العلامة' : 'Bookmark removed';
  String movedTo(String category) => isAr ? 'تم النقل إلى "$category" ✓' : 'Moved to "$category" ✓';
  String get editBookmark => isAr ? 'تعديل العلامة' : 'Edit bookmark';
  String get addBookmark => isAr ? 'إضافة علامة' : 'Add bookmark';
  String get notes => isAr ? 'ملاحظات' : 'Notes';
  String get edit => isAr ? 'تعديل' : 'Edit';
  String get delete => isAr ? 'حذف' : 'Delete';
  String get deleteBookmark => isAr ? 'حذف العلامة' : 'Delete bookmark';
  String get removeBookmark => isAr ? 'إزالة العلامة' : 'Remove bookmark';
  String get changeCategory => isAr ? 'تغيير التصنيف' : 'Change category';
  String get categoryChanged => isAr ? 'تم تغيير التصنيف ✓' : 'Category changed ✓';
  String deleteBookmarkConfirm(String surah, String verse) => isAr 
    ? 'هل تريد حذف العلامة من سورة $surah، الآية $verse؟'
    : 'Do you want to delete the bookmark from Surah $surah, Verse $verse?';
  String get noBookmarksInCategory => isAr ? 'لا توجد علامات في هذا التصنيف' : 'No bookmarks in this category';
  String get tryAnotherCategory => isAr ? 'جرّب اختيار تصنيف آخر أو عرض الكل' : 'Try another category or show all';
  String get noNotes => isAr ? 'لا توجد ملاحظات' : 'No notes';
  String get noNotesYet => isAr ? 'لا توجد ملاحظات بعد' : 'No notes yet';
  String get addNote => isAr ? 'إضافة ملاحظة' : 'Add note';
  String lastModifiedLabel(String date) =>
      isAr ? 'آخر تعديل: $date' : 'Last modified: $date';
  String notesVerseHeader(String surahName, String verse) => isAr
      ? 'ملاحظات • سورة $surahName • الآية $verse'
      : 'Notes • Surah $surahName • Verse $verse';
  String get note => isAr ? 'ملاحظة' : 'Note';
  String get writeNoteHint => isAr ? 'اكتب ملاحظتك هنا...' : 'Write your note here...';
  String get add => isAr ? 'إضافة' : 'Add';
  String get view => isAr ? 'عرض' : 'View';
  String get copiedToClipboard => isAr ? 'تم النسخ إلى الحافظة' : 'Copied to clipboard';

  // Bookmarks
  String get bookmarks => isAr ? 'العلامات المرجعية' : 'Bookmarks';
  String get manageCategories => isAr ? 'إدارة التصنيفات' : 'Manage Categories';
  String get newCategory => isAr ? 'تصنيف جديد' : 'New Category';
  String get editCategory => isAr ? 'تعديل التصنيف' : 'Edit Category';
  String get deleteCategory => isAr ? 'حذف التصنيف' : 'Delete Category';
  String get categoryName => isAr ? 'اسم التصنيف' : 'Category Name';
  String get color => isAr ? 'اللون' : 'Color';
  String get defaultCategory => isAr ? 'التصنيف الافتراضي' : 'Default Category';
  String get categoryGeneral => isAr ? 'عام' : 'General';
  String get categoryMemorization => isAr ? 'حفظ' : 'Memorization';
  String get categoryReview => isAr ? 'مراجعة' : 'Review';
  String get categoryTafsir => isAr ? 'تفسير' : 'Tafsir';

  String bookmarkCategoryTitle(String id, String storedTitle) {
    switch (id) {
      case 'default':
        return categoryGeneral;
      case 'memorization':
        return categoryMemorization;
      case 'review':
        return categoryReview;
      case 'tafsir':
        return categoryTafsir;
      default:
        return storedTitle;
    }
  }
  String get noCategories => isAr ? 'لا توجد تصنيفات' : 'No categories';
  String deleteCategoryConfirm(String title) => isAr
      ? 'هل تريد حذف تصنيف "$title"؟\nسيتم نقل العلامات المرتبطة به إلى التصنيف الافتراضي.'
      : 'Do you want to delete the category "$title"?\nAssociated bookmarks will be moved to the default category.';
  String get create => isAr ? 'إنشاء' : 'Create';
  String get categories => isAr ? 'التصنيفات' : 'Categories';
  String get all => isAr ? 'الكل' : 'All';
  String get noBookmarksYet => isAr ? 'لا توجد علامات مرجعية بعد' : 'No bookmarks yet';
  String get addBookmarkHint => isAr ? 'اضغط مطولاً على أي آية لإضافة علامة' : 'Long press any verse to add a bookmark';

  // Surah Header
  String get surahOrder => isAr ? 'ترتيبها' : 'Order';
  String get surahVerses => isAr ? 'آياتها' : 'Verses';
  String get surahLabel => isAr ? 'سورة' : 'Surah';

  // Whats New
  String get whatsNew => isAr ? 'ما الجديد؟' : 'What\'s New?';
  String get current => isAr ? 'الحالي' : 'Current';
  String get fixes => isAr ? 'الإصلاحات' : 'Fixes';
  String get improvements => isAr ? 'التحسينات' : 'Improvements';
  String get other => isAr ? 'أخرى' : 'Other';
  String get newFeatures => isAr ? 'ميزات جديدة' : 'New Features';
  String get performance => isAr ? 'الأداء' : 'Performance';
  String get ui => isAr ? 'واجهة المستخدم' : 'UI';
  String get bookmarksLabel => isAr ? 'العلامات' : 'Bookmarks';
  String get gotIt => isAr ? 'فهمت، شكراً' : 'Got it, thanks';

  String get sortBy => isAr ? 'الترتيب' : 'Sort by';
  String get searchInNotesHint => isAr ? 'ابحث داخل الملاحظات...' : 'Search in notes...';
  String get filterBySurah => isAr ? 'تصفية بالسورة' : 'Filter by Surah';
  String get allSurahs => isAr ? 'كل السور' : 'All Surahs';
  String get clearFilter => isAr ? 'إلغاء التصفية' : 'Clear filter';
  String get lastModifiedNewest => isAr ? 'آخر تعديل (الأحدث)' : 'Last modified (Newest)';
  String get lastModifiedOldest => isAr ? 'آخر تعديل (الأقدم)' : 'Last modified (Oldest)';
  String get dateCreatedNewest => isAr ? 'تاريخ الإنشاء (الأحدث)' : 'Date created (Newest)';
  String get dateCreatedOldest => isAr ? 'تاريخ الإنشاء (الأقدم)' : 'Date created (Oldest)';

  String get hizbLabel => isAr ? 'حزب' : 'Hizb';
  String get enterJuzNumber => isAr ? 'أدخل رقم الجزء' : 'Enter Juz number';
  String get enterHizbNumber => isAr ? 'أدخل رقم الحزب' : 'Enter Hizb number';
  String get enterPageNumber => isAr ? 'أدخل رقم الصفحة' : 'Enter page number';
  String get quarterLabel => isAr ? 'الربع' : 'Quarter';
  String get quarter1 => isAr ? 'الأول' : '1st';
  String get quarter2 => isAr ? 'الثاني' : '2nd';
  String get quarter3 => isAr ? 'الثالث' : '3rd';
  String get quarter4 => isAr ? 'الرابع' : '4th';
  String get invalidPageNumber => isAr ? 'الرجاء إدخال رقم صفحة صحيح' : 'Please enter a valid page number';
  String get enterPageNumberPrompt => isAr ? 'الرجاء إدخال رقم صفحة' : 'Please enter a page number';

  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return S(locale.languageCode);
  }
}
