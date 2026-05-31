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
  String get themeDynamic => isAr ? 'ألوان الجهاز' : 'Dynamic';
  String get themeSepia => isAr ? 'سيبيا' : 'Sepia';
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

  // Search
  String get searchHint => isAr ? 'ابحث عن آية...' : 'Search for a verse...';
  String get noResults => isAr ? 'لا توجد نتائج' : 'No results found';
  String get resultsCount => isAr ? 'عدد النتائج' : 'Results';
  String get matchExact => isAr ? 'مطابق' : 'Exact';
  String get matchPrefix => isAr ? 'بداية' : 'Prefix';
  String get matchContains => isAr ? 'داخل' : 'Contains';
  String get matchFlexible => isAr ? 'مرن' : 'Flexible';
  String get matchAllWords => isAr ? 'جميع الكلمات' : 'All words';
  String get matchAnyWord => isAr ? 'أي كلمة' : 'Any word';

  // Verse Menu
  String get copy => isAr ? 'نسخ' : 'Copy';
  String get bookmark => isAr ? 'علامة' : 'Bookmark';
  String get notes => isAr ? 'ملاحظات' : 'Notes';
  String get edit => isAr ? 'تعديل' : 'Edit';
  String get delete => isAr ? 'حذف' : 'Delete';
  String get add => isAr ? 'إضافة' : 'Add';
  String get view => isAr ? 'عرض' : 'View';
  String get copiedToClipboard => isAr ? 'تم النسخ إلى الحافظة' : 'Copied to clipboard';

  // Bookmarks
  String get bookmarks => isAr ? 'العلامات المرجعية' : 'Bookmarks';
  String get categories => isAr ? 'التصنيفات' : 'Categories';
  String get all => isAr ? 'الكل' : 'All';
  String get noBookmarksYet => isAr ? 'لا توجد علامات مرجعية بعد' : 'No bookmarks yet';
  String get addBookmarkHint => isAr ? 'اضغط مطولاً على أي آية لإضافة علامة' : 'Long press any verse to add a bookmark';

  // Surah Header
  String get surahOrder => isAr ? 'ترتيبها' : 'Order';
  String get surahVerses => isAr ? 'آياتها' : 'Verses';
  String get surahLabel => isAr ? 'سورة' : 'Surah';

  static S of(BuildContext context) {
    // This is a simplified version, ideally we'd use a provider or similar.
    // For now we'll pass the language string directly.
    return S('ar'); // Default, will be updated to use controller
  }
}
