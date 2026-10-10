import 'package:flutter/material.dart';
import 'package:my_quran/quran/quran.dart';

class S {
  final String lang;
  S([this.lang = 'ru']);

  bool get isAr => lang == 'ar';
  bool get isEn => lang == 'en';

  String surahName(int number) =>
      Quran.instance.getSurahNameLocalized(number, lang);

  // ── Navigation Sheet ──
  String get page => isEn ? 'Page' : 'Страница';
  String get surah => isEn ? 'Surah' : 'Сура';
  String get juz => isEn ? 'Juz' : 'Джуз';
  String get verse => isEn ? 'Ayah' : 'Аят';
  String get cancel => isEn ? 'Cancel' : 'Отмена';
  String get navigate => isEn ? 'Go to' : 'Перейти';

  // ── Settings ──
  String get settings => isEn ? 'Settings' : 'Настройки';
  String get font => isEn ? 'Font' : 'Шрифт';
  String get fontSize => isEn ? 'Font size' : 'Размер шрифта';
  String get fontWeight => isEn ? 'Font weight' : 'Жирность шрифта';
  String get fontWeightNormal => isEn ? 'Regular' : 'Обычный';
  String get fontWeightBold => isEn ? 'Bold' : 'Жирный';
  String get fontType => isEn ? 'Font style' : 'Тип шрифта';
  String get fontTypeUthmani => isEn ? 'Uthmani' : 'Усмани';
  String get fontTypeMadina => isEn ? 'Madinah' : 'Медина';
  String get reading => isEn ? 'Reading' : 'Чтение';
  String get textAndReading => isEn ? 'Text & Reading' : 'Текст и чтение';
  String get appearanceAndScreen =>
      isEn ? 'Appearance & Screen' : 'Оформление и экран';
  String get extraAndData =>
      isEn ? 'More & Data' : 'Дополнительно и данные';
  String get lineHeight => isEn ? 'Line height' : 'Высота строки';
  String get lineHeightAuto => isEn ? 'Auto' : 'Авто';
  String get textAlign => isEn ? 'Text alignment' : 'Выравнивание текста';
  String get textAlignJustify => isEn ? 'Justify' : 'По ширине';
  String get textAlignCenter => isEn ? 'Center' : 'По центру';
  String get textAlignStart => isEn ? 'Right edge' : 'По правому краю';
  String get narration => isEn ? 'Riwayah' : 'Риваят';
  String get narrationHafs => isEn ? 'Hafs' : 'Хафс';
  String get narrationWarsh => isEn ? 'Warsh' : 'Варш';
  String get appearance => isEn ? 'Appearance' : 'Оформление';
  String get themeDefault => isEn ? 'Default' : 'По умолчанию';
  String get themeMyQuran => isEn ? 'Classic' : 'Классическая';
  String get themeMyQuranDesc =>
      isEn ? 'Signature emerald theme' : 'Фирменная изумрудная тема';
  String get themeDynamic => isEn ? 'System' : 'Системная';
  String get themeDynamicDesc => isEn
      ? 'Uses system colors with auto-switching'
      : 'Использует цвета вашей системы с авто-переключением';
  String get themeSepia => isEn ? 'Sepia' : 'Сепия';
  String get themeSepiaDesc =>
      isEn ? 'Warm paper color, easy on the eyes' : 'Цвет бумаги, приятный для глаз';
  String get trueBlack => isEn ? 'Pure Black (AMOLED)' : 'Глубокий чёрный (AMOLED)';
  String get trueBlackDesc => isEn
      ? 'Pitch black background for dark theme'
      : 'Идеально чёрный фон для тёмной темы';
  String get general => isEn ? 'General' : 'Общие';
  String get bookMode => isEn ? 'Book mode' : 'Режим книги';
  String get bookModeDesc => isEn
      ? 'Horizontal page flipping'
      : 'Горизонтальное перелистывание страниц';
  String get verticalScroll =>
      isEn ? 'Vertical scroll' : 'Вертикальная прокрутка';
  String get keepScreenOn => isEn ? 'Keep screen on' : 'Не выключать экран';
  String get keepScreenOnDesc => isEn
      ? 'Prevents screen from turning off while reading'
      : 'Предотвращает выключение экрана во время чтения';
  String get showHizbNumber => isEn ? 'Hizb number' : 'Номер хизба';
  String get showHizbNumberDesc => isEn
      ? 'Show Hizb number instead of Juz'
      : 'Показывать номер хизба вместо джуза';
  String get hideQuarterNumber =>
      isEn ? 'Hide quarter number' : 'Скрыть номер четверти';
  String get language => isEn ? 'Language' : 'Язык';
  String get langAr => 'العربية';
  String get langEn => 'English';
  String get langRu => 'Русский';
  String get backup => isEn ? 'Backup & Restore' : 'Резервное копирование';
  String get backupDesc => isEn
      ? 'Export and import bookmarks and notes'
      : 'Экспорт и импорт закладок и заметок';
  String get exportBackup => isEn ? 'Export backup' : 'Экспорт копии';
  String get exportBackupDesc => isEn
      ? 'Share or save backup file'
      : 'Поделиться файлом или сохранить его';
  String get importBackup => isEn ? 'Import backup' : 'Импорт копии';
  String get importBackupDesc => isEn
      ? 'Merge with current data or replace it'
      : 'Объединить с текущими данными или заменить их';
  String get backupDate => isEn ? 'Date' : 'Дата';
  String get backupCategories => isEn ? 'Categories' : 'Категории';
  String get backupBookmarks => isEn ? 'Bookmarks' : 'Закладки';
  String get backupNotes => isEn ? 'Notes' : 'Заметки';
  String get chooseImportMode =>
      isEn ? 'Choose import mode:' : 'Выберите режим импорта:';
  String get merge => isEn ? 'Merge' : 'Объединить';
  String get replace => isEn ? 'Replace' : 'Заменить';
  String get importSuccess =>
      isEn ? 'Import completed successfully' : 'Импорт успешно завершён';
  String get importError => isEn ? 'Import error' : 'Ошибка импорта';
  String get success => isEn ? 'Success' : 'Успешно';
  String get save => isEn ? 'Save' : 'Сохранить';
  String get close => isAr ? 'إغلاق' : (isEn ? 'Close' : 'Закрыть');

  // ── About App ──
  String get aboutApp =>
      isAr ? 'حول التطبيق' : (isEn ? 'About App' : 'О приложении');
  String get appName =>
      isAr ? 'القرآن الكريم HD' : (isEn ? 'Quran HD' : 'Коран HD');
  String get appDescription => isAr
      ? 'مصحف إلكتروني بدون إنترنت وبدون إعلانات'
      : (isEn
          ? 'Clean offline Quran reading without ads'
          : 'Удобный офлайн-Коран без рекламы');
  String get sourceText =>
      isAr ? 'مصدر النص' : (isEn ? 'Text Source' : 'Источник текста');
  String get sourceTextDesc => isAr
      ? 'مجمع الملك فهد لطباعة المصحف الشريف (KFGQPC)'
      : (isEn
          ? 'King Fahd Quran Printing Complex (KFGQPC, Madinah)'
          : 'Комплекс имени Короля Фахда (KFGQPC, Медина)');
  String get fontsAndRiwayah =>
      isAr ? 'الروايات والخطوط' : (isEn ? 'Fonts & Narrations' : 'Шрифты и риваяты');
  String get fontsAndRiwayahDesc => isAr
      ? 'حفص وورش • خطوط عثمانية ومصحف المدينة'
      : (isEn
          ? 'Hafs & Warsh • Uthmanic & Madinah fonts'
          : 'Хафс и Варш • Усманский шрифт и Медина');
  String get privacyPolicy =>
      isAr ? 'سياسة الخصوصية' : (isEn ? 'Privacy Policy' : 'Политика конфиденциальности');
  String get privacyPolicyTapDesc => isAr
      ? 'يعمل محلياً بالكامل دون اتصال • اضغط للتفاصيل'
      : (isEn ? '100% offline • Tap to view' : '100% офлайн • Нажмите для просмотра');
  String get shareApp =>
      isAr ? 'مشاركة التطبيق' : (isEn ? 'Share App' : 'Поделиться приложением');
  String get shareAppDesc => isAr
      ? 'شارك التطبيق مع أهلك وأصدقائك'
      : (isEn ? 'Share app with family and friends' : 'Рассказать о приложении близким');
  String get shareAppMessage => isAr
      ? 'تطبيق القرآن الكريم HD لقراءة القرآن الكريم بدون إنترنت وبدون إعلانات'
      : (isEn
          ? 'Quran HD — clean offline Quran reading app without ads.'
          : 'Коран HD — удобное чтение Корана без интернета и рекламы.');

  // ── Reading Stats ──
  String get readingStats =>
      isAr ? 'إحصائيات القراءة' : (isEn ? 'Reading Stats' : 'Статистика чтения');
  String get readingTimeToday =>
      isAr ? 'الوقت اليوم' : (isEn ? 'Time Today' : 'Время сегодня');
  String get readingStreak =>
      isAr ? 'أيام متتالية' : (isEn ? 'Daily Streak' : 'Дней подряд');
  String get khatmProgress =>
      isAr ? 'ختمة القرآن' : (isEn ? 'Khatm Progress' : 'Прогресс Хатма');
  String get todayPages =>
      isAr ? 'صفحات اليوم' : (isEn ? 'Pages Today' : 'Страниц сегодня');
  String get pagesUnit => isEn ? 'pp.' : 'стр.';
  String get minutesShort => isAr ? 'د' : (isEn ? 'm' : 'мин');
  String get hoursShort => isAr ? 'س' : (isEn ? 'h' : 'ч');
  String get daysShort => isAr ? 'يوم' : (isEn ? 'd' : 'дн.');
  String get resetKhatm =>
      isAr ? 'بدء ختمة جديدة' : (isEn ? 'Start New Khatm' : 'Начать новый Хатм');
  String get resetKhatmConfirm => isAr
      ? 'هل تريد إعادة تعيين تقدم الختمة الحالية والبدء من جديد؟'
      : (isEn
          ? 'Reset current Khatm progress and start fresh?'
          : 'Сбросить прогресс текущего прочтения Корана и начать новый Хатм?');

  // ── Search ──
  String get searchHint => isEn ? 'Search ayahs...' : 'Поиск по аятам...';
  String get noResults => isEn ? 'No results found' : 'Ничего не найдено';
  String get resultsCount => isEn ? 'Results' : 'Результаты';
  String showingNofM(int n, int m) =>
      isEn ? 'Showing $n of $m' : 'Показано $n из $m';
  String resultsCountN(int n) =>
      isEn ? 'Total results: $n' : 'Всего результатов: $n';
  String foundAyahsCount(int n) =>
      isEn ? 'Found ayahs ($n):' : 'Найденные аяты ($n):';
  String get matchExact => isEn ? 'Exact' : 'Точное';
  String get matchPrefix => isEn ? 'Word start' : 'Начало слова';
  String get matchContains => isEn ? 'Contains' : 'Содержит';
  String get matchFlexible => isEn ? 'Flexible' : 'Гибкое';
  String get matchAllWords => isEn ? 'All words' : 'Все слова';
  String get matchAnyWord => isEn ? 'Any word' : 'Любое слово';
  String get matchLabel => isEn ? 'Match' : 'Совпадение';

  // ── Verse Menu & Bookmarks ──
  String get copy => isEn ? 'Copy' : 'Копировать';
  String get copyVerse => isEn ? 'Copy Ayah' : 'Копировать аят';
  String get bookmark => isEn ? 'Bookmark' : 'Закладка';
  String get bookmarkAdded => isEn ? 'Bookmark added ✓' : 'Закладка добавлена ✓';
  String get bookmarkRemoved => isEn ? 'Bookmark removed' : 'Закладка удалена';
  String movedTo(String category) =>
      isEn ? 'Moved to "$category" ✓' : 'Перемещено в «$category» ✓';
  String get editBookmark => isEn ? 'Edit Bookmark' : 'Изменить закладку';
  String get addBookmark => isEn ? 'Add Bookmark' : 'Добавить закладку';
  String get notes => isEn ? 'Notes' : 'Заметки';
  String get edit => isEn ? 'Edit' : 'Изменить';
  String get delete => isEn ? 'Delete' : 'Удалить';
  String get deleteBookmark => isEn ? 'Delete Bookmark' : 'Удалить закладку';
  String get removeBookmark => isEn ? 'Remove Bookmark' : 'Убрать закладку';
  String get changeCategory => isEn ? 'Change Category' : 'Сменить категорию';
  String get categoryChanged => isEn ? 'Category changed ✓' : 'Категория изменена ✓';
  String deleteBookmarkConfirm(String surah, String verse) => isEn
      ? 'Delete bookmark for Surah $surah, Ayah $verse?'
      : 'Удалить закладку из суры $surah, аят $verse?';
  String get noBookmarksInCategory =>
      isEn ? 'No bookmarks in this category' : 'В этой категории нет закладок';
  String get tryAnotherCategory => isEn
      ? 'Choose another category or show all'
      : 'Выберите другую категорию или покажите все';
  String get noNotes => isEn ? 'No notes' : 'Нет заметок';
  String get noNotesYet => isEn ? 'No notes yet' : 'Заметок пока нет';
  String get addNote => isEn ? 'Add Note' : 'Добавить заметку';
  String lastModifiedLabel(String date) =>
      isEn ? 'Modified: $date' : 'Изменено: $date';
  String notesVerseHeader(String surahName, String verse) =>
      isEn ? 'Notes • Surah $surahName • Ayah $verse' : 'Заметки • Сура $surahName • Аят $verse';
  String get note => isEn ? 'Note' : 'Заметка';
  String get writeNoteHint => isEn ? 'Write a note...' : 'Напишите заметку...';
  String get deleteNote =>
      isAr ? 'حذف الملاحظة' : (isEn ? 'Delete Note' : 'Удалить заметку');
  String get deleteNoteConfirm => isAr
      ? 'هل أنت متأكد من حذف هذه الملاحظة؟'
      : (isEn ? 'Delete this note?' : 'Удалить эту заметку?');
  String get add => isEn ? 'Add' : 'Добавить';
  String get view => isEn ? 'View' : 'Просмотр';
  String get copiedToClipboard =>
      isEn ? 'Copied to clipboard' : 'Скопировано в буфер обмена';

  // ── Bookmarks Management ──
  String get bookmarks => isEn ? 'Bookmarks' : 'Закладки';
  String get manageCategories =>
      isEn ? 'Manage Categories' : 'Управление категориями';
  String get newCategory => isEn ? 'New Category' : 'Новая категория';
  String get editCategory => isEn ? 'Edit Category' : 'Редактировать категорию';
  String get deleteCategory => isEn ? 'Delete Category' : 'Удалить категорию';
  String get categoryName => isEn ? 'Category name' : 'Название категории';
  String get color => isEn ? 'Color' : 'Цвет';
  String get defaultCategory =>
      isEn ? 'Default category' : 'Категория по умолчанию';
  String get categoryGeneral => isEn ? 'General' : 'Общее';
  String get categoryMemorization => isEn ? 'Memorization' : 'Заучивание';
  String get categoryReview => isEn ? 'Revision' : 'Повторение';
  String get categoryTafsir => isEn ? 'Tafsir' : 'Тафсир';

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

  String get noCategories => isEn ? 'No categories' : 'Нет категорий';
  String deleteCategoryConfirm(String title) => isEn
      ? 'Delete category "$title"?\nAssociated bookmarks will move to General.'
      : 'Удалить категорию «$title»?\nСвязанные закладки будут перемещены в категорию по умолчанию.';
  String get create => isEn ? 'Create' : 'Создать';
  String get categories => isEn ? 'Categories' : 'Категории';
  String get all => isEn ? 'All' : 'Все';
  String get noBookmarksYet => isEn ? 'No bookmarks yet' : 'Закладок пока нет';
  String get addBookmarkHint => isEn
      ? 'Long-press any ayah to add a bookmark'
      : 'Удерживайте нажатие на любом аяте, чтобы добавить закладку';

  // ── Surah Header Banner ──
  String get surahOrder => isEn ? 'Order' : 'Номер';
  String get surahVerses => isEn ? 'Ayahs' : 'Аятов';
  String get surahLabel => isEn ? 'Surah' : 'Сура';

  // ── What's New ──
  String get whatsNew => isEn ? "What's New" : 'Что нового?';
  String get current => isEn ? 'Current' : 'Текущая';
  String get fixes => isEn ? 'Fixes' : 'Исправления';
  String get improvements => isEn ? 'Improvements' : 'Улучшения';
  String get other => isEn ? 'Other' : 'Прочее';
  String get newFeatures => isEn ? 'New Features' : 'Новые функции';
  String get performance => isEn ? 'Performance' : 'Производительность';
  String get ui => isEn ? 'Interface' : 'Интерфейс';
  String get bookmarksLabel => isEn ? 'Bookmarks' : 'Закладки';
  String get gotIt => isEn ? 'Got it' : 'Понятно';

  String get sortBy => isEn ? 'Sort by' : 'Сортировка';
  String get searchInNotesHint =>
      isEn ? 'Search notes...' : 'Поиск в заметках...';
  String get filterBySurah => isEn ? 'Filter by surah' : 'Фильтр по суре';
  String get allSurahs => isEn ? 'All surahs' : 'Все суры';
  String get clearFilter => isEn ? 'Clear filter' : 'Сбросить фильтр';
  String get lastModifiedNewest =>
      isEn ? 'Last modified (newest)' : 'По изменению (новые)';
  String get lastModifiedOldest =>
      isEn ? 'Last modified (oldest)' : 'По изменению (старые)';
  String get dateCreatedNewest =>
      isEn ? 'Date created (newest)' : 'По дате создания (новые)';
  String get dateCreatedOldest =>
      isEn ? 'Date created (oldest)' : 'По дате создания (старые)';

  String get hizbLabel => isEn ? 'Hizb' : 'Хизб';
  String get enterJuzNumber => isEn ? 'Enter Juz number' : 'Введите номер джуза';
  String get enterHizbNumber => isEn ? 'Enter Hizb number' : 'Введите номер хизба';
  String get enterPageNumber => isEn ? 'Enter page number' : 'Введите номер страницы';
  String get quarterLabel => isEn ? 'Quarter' : 'Четверть';
  String get quarter1 => isEn ? '1st' : '1-я';
  String get quarter2 => isEn ? '2nd' : '2-я';
  String get quarter3 => isEn ? '3rd' : '3-я';
  String get quarter4 => isEn ? '4th' : '4-я';
  String get invalidPageNumber => isEn
      ? 'Please enter a valid page number'
      : 'Пожалуйста, введите корректный номер страницы';
  String get enterPageNumberPrompt =>
      isEn ? 'Please enter page number' : 'Пожалуйста, введите номер страницы';

  // ── Ribbon Page Bookmark ──
  String ribbonTooltipOnPage(String page) => isAr
      ? 'علامة القراءة في صفحة $page • انقر للإزالة'
      : (isEn
          ? 'Bookmark on p. $page • Tap to remove'
          : 'Закладка на стр. $page • Нажмите, чтобы снять');

  String ribbonTooltipElsewhere(String page) => isAr
      ? 'العلامة في صفحة $page • انقر للانتقال، اضغط مطولاً للوضع هنا'
      : (isEn
          ? 'Bookmark on p. $page • Tap to jump, hold to place here'
          : 'Закладка на стр. $page • Нажмите для перехода, удерживайте чтобы переложить');

  String ribbonTooltipSet(String page) => isAr
      ? 'وضع علامة في صفحة $page'
      : (isEn ? 'Bookmark p. $page' : 'Поставить закладку на стр. $page');

  String ribbonRemoved(String page) => isAr
      ? 'تمت إزالة العلامة من صفحة $page'
      : (isEn
          ? 'Bookmark removed from p. $page'
          : 'Закладка убрана со стр. $page');

  String ribbonJump(String page) => isAr
      ? 'الانتقال إلى صفحة $page'
      : (isEn
          ? 'Jump to bookmark (p. $page)'
          : 'Переход к закладке (стр. $page)');

  String ribbonPlaced(String page) => isAr
      ? 'تم وضع العلامة في صفحة $page'
      : (isEn
          ? 'Bookmark set on p. $page'
          : 'Закладка поставлена на стр. $page');

  String ribbonMoved(String page) => isAr
      ? 'تم نقل العلامة إلى صفحة $page'
      : (isEn
          ? 'Bookmark moved to p. $page'
          : 'Закладка переложена на стр. $page');

  String ribbonNavChip(String surah, String page) => isAr
      ? 'علامة القراءة: $surah (صفحة $page)'
      : (isEn
          ? 'Bookmark: $surah (p. $page)'
          : 'Закладка: $surah (стр. $page)');

  // ── Khatm Celebration & Split-view ──
  String get khatmCongratulations => isAr
      ? 'مبارك ختم القرآن الكريم!'
      : (isEn
          ? 'Congratulations on Completing Khatm!'
          : 'Поздравляем с завершением Хатма!');
  String get khatmCompletedDesc => isAr
      ? 'لقد أتممت قراءة 604 صفحات من القرآن الكريم. تقبل الله منكم صالح الأعمال!'
      : (isEn
          ? 'You have read all 604 pages of the Holy Quran. May Allah accept your reading!'
          : 'Вы прочитали все 604 страницы Священного Корана. Да примет Всевышний ваше чтение!');
  String get khatmDuaTitle => isAr
      ? 'دعاء ختم القرآن'
      : (isEn ? 'Dua of Khatm Quran' : 'Дуа завершения Корана');
  String get khatmDuaText => isAr
      ? 'اللَّهُمَّ ارْحَمْنِي بِالقُرْآنِ، وَاجْعَلْهُ لِي إِمَاماً وَنُوراً وَهُدًى وَرَحْمَةً، اللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نَسِيتُ، وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ، وَارْزُقْنِي تِلاَوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ.'
      : (isEn
          ? 'O Allah, have mercy upon me through the Quran, and make it for me a guide, light, guidance, and mercy. O Allah, remind me of what I have forgotten of it, and teach me of it what I do not know.'
          : 'اللَّهُمَّ ارْحَمْنِي بِالقُرْآنِ، وَاجْعَلْهُ لِي إِمَاماً وَنُوراً وَهُدًى وَرَحْمَةً\n\n«О Аллах, помилуй меня посредством Корана, сделай его для меня предводителем, светом, верным руководством и милостью. Напомни мне то, что я забыл, и научи тому, чего я не знал».');
  String get startNewKhatm => isAr
      ? 'بدء ختمة جديدة'
      : (isEn ? 'Start New Khatm' : 'Начать новый Хатм');
  String get selectItemToPreview => isAr
      ? 'اختر عنصراً للمعاينة'
      : (isEn ? 'Select an item to preview' : 'Выберите элемент для просмотра');
  String get goToVerse => isAr
      ? 'الانتقال إلى الآية'
      : (isEn ? 'Go to verse' : 'Перейти к аяту');

  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return S(locale.languageCode);
  }
}
