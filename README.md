<div align="center">

  <img src="fastlane/metadata/android/en-US/images/icon.png" alt="Logo" width="120" height="120">
  <br>

  # My Quran Book

  Licensed under [GNU GPL v3](LICENSE). Source: [solemetra/my_quran_book](https://github.com/solemetra/my_quran_book)

</div>

---

## О проекте

Удобное, быстрое и полностью автономное приложение для чтения Священного Корана на планшетах и смартфонах.

| | |
|---|---|
| **Репозиторий** | https://github.com/solemetra/my_quran_book |
| **Лицензия** | GPL-3.0 |

### Changes in this fork (vs upstream 1.7.6)

- English UI for menus and settings (Arabic Quran text and surah names unchanged)
- Navigation: **Surah number → Juz → Verse** (page picker removed; surah name shown above wheels)
- Al-Fatiha: Basmala shown separately; verse 1 not duplicated in body text
- RTL forced for Quran text when UI language is English
- Flutter SDK constraint relaxed for local builds (`>=3.38.5`)

---

Lightweight offline Quran reader with fast search. No internet required. No analytics.  
Hafs and Warsh readings.

---

## Build from source

```bash
git clone https://github.com/solemetra/my_quran_book.git
cd my_quran_book
flutter pub get
flutter run
```

---

## Legal

- **Software**: [GNU General Public License v3](LICENSE) — you may use, modify, and redistribute under GPL terms.
- **Third-party fonts and Quran data**: see [NOTICE.md](NOTICE.md) (KFGQPC fonts, Scheherazade, etc.).
- **Copyright**: see [COPYRIGHT.md](COPYRIGHT.md).

---

<div align="center">

  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/0-reading.png" width="200" />
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1-navigation.png" width="200" />
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2-appearance.png" width="200" />

</div>
