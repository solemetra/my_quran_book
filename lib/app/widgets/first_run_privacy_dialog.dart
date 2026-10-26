import 'package:my_quran/app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design_tokens.dart';
import '../l10n.dart';
import '../settings_controller.dart';

/// Dialog shown on the very first launch of the application
/// in full compliance with Huawei AppGallery Rule 7.5.
class FirstRunPrivacyDialog extends StatefulWidget {
  const FirstRunPrivacyDialog({
    required this.settingsController,
    super.key,
  });

  final SettingsController settingsController;

  static const String _acceptedKey = 'privacy_policy_accepted_v1';

  /// Checks if privacy consent has been granted. If not, shows the dialog.
  static Future<void> showIfNeeded(
    BuildContext context, {
    required SettingsController settingsController,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_acceptedKey) ?? false;
    if (accepted) return;
    if (!context.mounted) return;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FirstRunPrivacyDialog(
        settingsController: settingsController,
      ),
    );
  }

  @override
  State<FirstRunPrivacyDialog> createState() => _FirstRunPrivacyDialogState();
}

class _FirstRunPrivacyDialogState extends State<FirstRunPrivacyDialog> {
  late String _currentLang;

  @override
  void initState() {
    super.initState();
    _currentLang = widget.settingsController.language;
  }

  Future<void> _onAgree(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(FirstRunPrivacyDialog._acceptedKey, true);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(true);
    }
  }

  void _onDisagree(BuildContext context) {
    // Under AppGallery Rule 7.5, if user does not agree, app must offer exit
    SystemNavigator.pop();
  }

  void _setLanguage(String lang) {
    if (_currentLang == lang) return;
    setState(() {
      _currentLang = lang;
    });
    widget.settingsController.language = lang;
  }

  @override
  Widget build(BuildContext context) {
    final s = S(_currentLang);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = s.isAr;
    final isEn = s.isEn;

    final title = isAr
        ? 'مرحباً بكم في ${s.appName}'
        : (isEn ? 'Welcome to ${s.appName}' : 'Добро пожаловать в ${s.appName}');

    final intro = isAr
        ? 'قبل بدء الاستخدام، يُرجى تأكيد موافقتكم على سياسة الخصوصية. التطبيق صُمم ليكون آمناً وخالياً تماماً من أي جمع للبيانات:'
        : (isEn
            ? 'Before you begin, please review and accept our Privacy Policy. The application is completely private and collects zero data:'
            : 'Перед началом использования ознакомьтесь с политикой конфиденциальности. Приложение разработано с заботой о вашей приватности:');

    final agreeBtnText = isAr
        ? 'موافق ومتابعة'
        : (isEn ? 'Accept & Continue' : 'Принять и продолжить');

    final exitBtnText = isAr
        ? 'خروج'
        : (isEn ? 'Exit' : 'Выход');

    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Md3SpringAppear(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: colorScheme.primary.applyOpacity(0.28),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.applyOpacity(0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: colorScheme.onPrimaryContainer,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr
                                  ? 'حماية الخصوصية والأمان'
                                  : (isEn
                                      ? 'Privacy & Security Protection'
                                      : 'Защита конфиденциальности'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Language switch pills right inside the dialog
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outlineVariant.applyOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _langChip(
                              label: 'RU',
                              selected: _currentLang == 'ru',
                              onTap: () => _setLanguage('ru'),
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 2),
                            _langChip(
                              label: 'EN',
                              selected: _currentLang == 'en',
                              onTap: () => _setLanguage('en'),
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    intro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _bulletPoint(
                    context,
                    title: isAr
                        ? '١٠٠٪ بدون إنترنت'
                        : (isEn ? '100% Offline' : '100% Офлайн'),
                    desc: isAr
                        ? 'يعمل التطبيق بالكامل محلياً على جهازك ولا يتطلب أي اتصال بالشبكة.'
                        : (isEn
                            ? 'The app runs entirely offline and requires no internet connection.'
                            : 'Приложение работает автономно и не требует интернета.'),
                  ),
                  const SizedBox(height: 10),
                  _bulletPoint(
                    context,
                    title: isAr
                        ? 'لا نجمع أي بيانات'
                        : (isEn ? 'Zero Data Collection' : 'Без сбора данных'),
                    desc: isAr
                        ? 'لا نقوم بجمع أو حفظ أو إرسال أي بيانات شخصية أو معلومات عن جهازك.'
                        : (isEn
                            ? 'We do not collect, store, or transmit any personal data or identifiers.'
                            : 'Мы не собираем и не передаем персональные данные или аналитику.'),
                  ),
                  const SizedBox(height: 10),
                  _bulletPoint(
                    context,
                    title: isAr
                        ? 'بدون إعلانات'
                        : (isEn ? 'No Ads & No Trackers' : 'Без рекламы и трекеров'),
                    desc: isAr
                        ? 'التطبيق خالٍ تماماً من الإعلانات ومن أي برمجيات تتبع تجارية.'
                        : (isEn
                            ? 'Completely free from advertising and third-party tracking modules.'
                            : 'Полностью свободно от рекламы и сторонних трекеров.'),
                  ),
                  const SizedBox(height: 10),
                  _bulletPoint(
                    context,
                    title: isAr
                        ? 'حفظ محلي فقط'
                        : (isEn ? 'Local Storage Only' : 'Локальное хранение'),
                    desc: isAr
                        ? 'جميع ملاحظاتك وإشاراتك المرجعية مخزنة في جهازك فقط.'
                        : (isEn
                            ? 'All bookmarks and notes remain exclusively inside your device.'
                            : 'Все ваши закладки и заметки хранятся только на устройстве.'),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _onDisagree(context),
                        child: Text(
                          exitBtnText,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _onAgree(context),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(agreeBtnText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _langChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _bulletPoint(
    BuildContext context, {
    required String title,
    required String desc,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: desc,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
