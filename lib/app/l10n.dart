import 'package:flutter/material.dart';

class S {
  final String lang;
  S([this.lang = 'ru']);

  bool get isAr => lang == 'ar';
  bool get isEn => lang == 'en';

  // Шторка навигации
  String get page => 'Страница';
  String get surah => 'Сура';
  String get juz => 'Джуз';
  String get verse => 'Аят';
  String get cancel => 'Отмена';
  String get navigate => 'Перейти';

  // Настройки
  String get settings => 'Настройки';
  String get font => 'Шрифт';
  String get fontSize => 'Размер шрифта';
  String get fontWeight => 'Жирность шрифта';
  String get fontWeightNormal => 'Обычный';
  String get fontWeightBold => 'Жирный';
  String get fontType => 'Тип шрифта';
  String get fontTypeUthmani => 'Усмани';
  String get fontTypeMadina => 'Медина';
  String get reading => 'Чтение';
  String get textAndReading => 'Текст и чтение';
  String get appearanceAndScreen => 'Оформление и экран';
  String get extraAndData => 'Дополнительно и данные';
  String get lineHeight => 'Высота строки';
  String get lineHeightAuto => 'Авто';
  String get textAlign => 'Выравнивание текста';
  String get textAlignJustify => 'По ширине';
  String get textAlignCenter => 'По центру';
  String get textAlignStart => 'По правому краю';
  String get narration => 'Риваят';
  String get narrationHafs => 'Хафс';
  String get narrationWarsh => 'Варш';
  String get appearance => 'Оформление';
  String get themeDefault => 'По умолчанию';
  String get themeMyQuran => 'Классическая';
  String get themeMyQuranDesc => 'Фирменная изумрудная тема';
  String get themeDynamic => 'Системная';
  String get themeDynamicDesc =>
      'Использует цвета вашей системы с авто-переключением';
  String get themeSepia => 'Сепия';
  String get themeSepiaDesc => 'Цвет бумаги, приятный для глаз';
  String get trueBlack => 'Глубокий чёрный (AMOLED)';
  String get trueBlackDesc => 'Идеально чёрный фон для тёмной темы';
  String get general => 'Общие';
  String get bookMode => 'Режим книги';
  String get bookModeDesc => 'Горизонтальное перелистывание страниц';
  String get verticalScroll => 'Вертикальная прокрутка';
  String get keepScreenOn => 'Не выключать экран';
  String get keepScreenOnDesc => 'Предотвращает выключение экрана во время чтения';
  String get showHizbNumber => 'Номер хизба';
  String get showHizbNumberDesc => 'Показывать номер хизба вместо джуза';
  String get hideQuarterNumber => 'Скрыть номер четверти';
  String get language => 'Язык';
  String get langAr => 'العربية';
  String get langEn => 'English';
  String get langRu => 'Русский';
  String get backup => 'Резервное копирование';
  String get backupDesc => 'Экспорт и импорт закладок и заметок';
  String get exportBackup => 'Экспорт копии';
  String get exportBackupDesc => 'Поделиться файлом или сохранить его';
  String get importBackup => 'Импорт копии';
  String get importBackupDesc => 'Объединить с текущими данными или заменить их';
  String get backupDate => 'Дата';
  String get backupCategories => 'Категории';
  String get backupBookmarks => 'Закладки';
  String get backupNotes => 'Заметки';
  String get chooseImportMode => 'Выберите режим импорта:';
  String get merge => 'Объединить';
  String get replace => 'Заменить';
  String get importSuccess => 'Импорт успешно завершён';
  String get importError => 'Ошибка импорта';
  String get success => 'Успешно';
  String get save => 'Сохранить';

  // Статистика чтения
  String get readingStats => isAr ? 'إحصائيات القراءة' : 'Статистика чтения';
  String get readingTimeToday => isAr ? 'الوقت اليوم' : 'Время сегодня';
  String get readingStreak => isAr ? 'أيام متتالية' : 'Дней подряд';
  String get khatmProgress => isAr ? 'ختمة القرآن' : 'Прогресс Хатма';
  String get todayPages => isAr ? 'صفحات اليوم' : 'Страниц сегодня';
  String get pagesUnit => 'стр.';
  String get minutesShort => isAr ? 'د' : 'мин';
  String get hoursShort => isAr ? 'س' : 'ч';
  String get daysShort => isAr ? 'يوم' : 'дн.';
  String get resetKhatm => isAr ? 'بدء ختمة جديدة' : 'Начать новый Хатм';
  String get resetKhatmConfirm => isAr
      ? 'هل تريد إعادة تعيين تقدم الختمة الحالية والبدء من جديد؟'
      : 'Сбросить прогресс текущего прочтения Корана и начать новый Хатм?';

  // Поиск
  String get searchHint => 'Поиск по аятам...';
  String get noResults => 'Ничего не найдено';
  String get resultsCount => 'Результаты';
  String showingNofM(int n, int m) => 'Показано $n из $m';
  String resultsCountN(int n) => 'Всего результатов: $n';
  String get matchExact => 'Точное';
  String get matchPrefix => 'Начало слова';
  String get matchContains => 'Содержит';
  String get matchFlexible => 'Гибкое';
  String get matchAllWords => 'Все слова';
  String get matchAnyWord => 'Любое слово';
  String get matchLabel => 'Совпадение';

  // Меню аята
  String get copy => 'Копировать';
  String get copyVerse => 'Копировать аят';
  String get bookmark => 'Закладка';
  String get bookmarkAdded => 'Закладка добавлена ✓';
  String get bookmarkRemoved => 'Закладка удалена';
  String movedTo(String category) => 'Перемещено в «$category» ✓';
  String get editBookmark => 'Изменить закладку';
  String get addBookmark => 'Добавить закладку';
  String get notes => 'Заметки';
  String get edit => 'Изменить';
  String get delete => 'Удалить';
  String get deleteBookmark => 'Удалить закладку';
  String get removeBookmark => 'Убрать закладку';
  String get changeCategory => 'Сменить категорию';
  String get categoryChanged => 'Категория изменена ✓';
  String deleteBookmarkConfirm(String surah, String verse) =>
      'Удалить закладку из суры $surah, аят $verse?';
  String get noBookmarksInCategory => 'В этой категории нет закладок';
  String get tryAnotherCategory => 'Выберите другую категорию или покажите все';
  String get noNotes => 'Нет заметок';
  String get noNotesYet => 'Заметок пока нет';
  String get addNote => 'Добавить заметку';
  String lastModifiedLabel(String date) => 'Изменено: $date';
  String notesVerseHeader(String surahName, String verse) =>
      'Заметки • Сура $surahName • Аят $verse';
  String get note => 'Заметка';
  String get writeNoteHint => 'Напишите заметку...';
  String get deleteNote => isAr ? 'حذف الملاحظة' : (isEn ? 'Delete Note' : 'Удалить заметку');
  String get deleteNoteConfirm => isAr
      ? 'هل أنت متأكد من حذف هذه الملاحظة؟'
      : (isEn ? 'Are you sure you want to delete this note?' : 'Удалить эту заметку?');
  String get add => 'Добавить';
  String get view => 'Просмотр';
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  // Закладки
  String get bookmarks => 'Закладки';
  String get manageCategories => 'Управление категориями';
  String get newCategory => 'Новая категория';
  String get editCategory => 'Редактировать категорию';
  String get deleteCategory => 'Удалить категорию';
  String get categoryName => 'Название категории';
  String get color => 'Цвет';
  String get defaultCategory => 'Категория по умолчанию';
  String get categoryGeneral => 'Общее';
  String get categoryMemorization => 'Заучивание';
  String get categoryReview => 'Повторение';
  String get categoryTafsir => 'Тафсир';

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

  String get noCategories => 'Нет категорий';
  String deleteCategoryConfirm(String title) =>
      'Удалить категорию «$title»?\nСвязанные закладки будут перемещены в категорию по умолчанию.';
  String get create => 'Создать';
  String get categories => 'Категории';
  String get all => 'Все';
  String get noBookmarksYet => 'Закладок пока нет';
  String get addBookmarkHint =>
      'Удерживайте нажатие на любом аяте, чтобы добавить закладку';

  // Шапка суры
  String get surahOrder => 'Номер';
  String get surahVerses => 'Аятов';
  String get surahLabel => 'Сура';

  // Что нового
  String get whatsNew => 'Что нового?';
  String get current => 'Текущая';
  String get fixes => 'Исправления';
  String get improvements => 'Улучшения';
  String get other => 'Прочее';
  String get newFeatures => 'Новые функции';
  String get performance => 'Производительность';
  String get ui => 'Интерфейс';
  String get bookmarksLabel => 'Закладки';
  String get gotIt => 'Понятно';

  String get sortBy => 'Сортировка';
  String get searchInNotesHint => 'Поиск в заметках...';
  String get filterBySurah => 'Фильтр по суре';
  String get allSurahs => 'Все суры';
  String get clearFilter => 'Сбросить фильтр';
  String get lastModifiedNewest => 'По изменению (новые)';
  String get lastModifiedOldest => 'По изменению (старые)';
  String get dateCreatedNewest => 'По дате создания (новые)';
  String get dateCreatedOldest => 'По дате создания (старые)';

  String get hizbLabel => 'Хизб';
  String get enterJuzNumber => 'Введите номер джуза';
  String get enterHizbNumber => 'Введите номер хизба';
  String get enterPageNumber => 'Введите номер страницы';
  String get quarterLabel => 'Четверть';
  String get quarter1 => '1-я';
  String get quarter2 => '2-я';
  String get quarter3 => '3-я';
  String get quarter4 => '4-я';
  String get invalidPageNumber =>
      'Пожалуйста, введите корректный номер страницы';
  String get enterPageNumberPrompt => 'Пожалуйста, введите номер страницы';

  // Khatm Celebration & Split-view
  String get khatmCongratulations => isAr
      ? 'مبارك ختم القرآن الكريم!'
      : (isEn ? 'Congratulations on Completing Khatm!' : 'Поздравляем с завершением Хатма!');
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
    return S('ru');
  }
}
