# Third-party notices

This app bundles materials from upstream [My Quran](https://github.com/dmouayad/my_quran) and third parties. This fork (`solemetra/my_quran_book`) distributes them under the same conditions as the upstream project, plus GPL-3.0 for modified source code.

## Quran text data

| Asset | Source / notes |
|-------|----------------|
| `assets/quran.json`, `assets/kfgqpc_hafs.json` | Upstream project; Hafs / Medina layouts |
| `assets/warsh.json` | Derived from data published by [King Fahd Complex](https://qurancomplex.gov.sa/) (see `lib/tool/convert_warsh.dart`) |
| `assets/search_index_*.json` | Generated indexes (upstream tooling) |

Quran text is not translated or altered in this fork except as inherited from upstream.

## Fonts

| Font file | Family | License / terms |
|-----------|--------|-----------------|
| `assets/fonts/HafsSmart.ttf` | Hafs | [KFGQPC end-user license](https://www.qurancomplex.gov.sa/) — use and distribution allowed; **do not modify** the font software |
| `assets/fonts/kfgqpc` layout (via JSON) | Hafs | Same as KFGQPC |
| `assets/fonts/uthmanic_warsh_v21.ttf` | Warsh | Upstream bundle; follow publisher terms |
| `assets/fonts/rustam_quranR3HOQ.ttf` | Rustam (Madina) | Upstream bundle |
| `assets/fonts/subset-ScheherazadeNew.ttf` | Scheherazade | [SIL Open Font License](https://scripts.sil.org/OFL) (Scheherazade New) |

If you redistribute APKs or other binaries, ensure compliance with KFGQPC and other font licenses in addition to GPL-3.0 for the application source code.

## Flutter / Dart dependencies

Runtime packages are listed in `pubspec.yaml` / `pubspec.lock` (pub.dev). They are typically BSD- or MIT-licensed and are compatible with GPL-3.0 when combined in this application.

For exact license texts of dependencies, run:

```bash
flutter pub licenses
```

## Trademarks

“My Quran”, “قرآني”, and `com.dmouayad.my_quran` refer to the upstream project by Mouayad Alhamwi. This fork is maintained separately and is not endorsed by the original author unless stated otherwise.
