import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onlysmart_ui/onlysmart_ui.dart';
import 'package:tuner_dombyra/localization/app_localizations.dart';
import 'package:tuner_dombyra/presentation/providers/settings_provider.dart';
import 'package:tuner_dombyra/presentation/providers/tuner_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.settings;

        return OnlySmartSettingsScaffold(
          title: l10n.settings,
          children: [
            OnlySmartSettingsSection(
              title: l10n.appearance,
              children: [
                OnlySmartSettingsThemeTile(
                  title: l10n.themeMode,
                  valueText: _getThemeModeText(settings.themeMode, l10n),
                  onTap: () async {
                    final selected = await showThemeDialog(
                      context: context,
                      currentValue: _toThemeModeOption(settings.themeMode),
                      title: l10n.themeMode,
                      labelFor: (option) {
                        switch (option) {
                          case ThemeModeOption.system: return l10n.system;
                          case ThemeModeOption.light: return l10n.light;
                          case ThemeModeOption.dark: return l10n.dark;
                        }
                      },
                    );
                    if (selected != null) {
                      final mode = selected.toFlutterThemeMode().name;
                      await settingsProvider.updateThemeMode(mode);
                    }
                  },
                ),
                OnlySmartSettingsLanguageTile(
                  title: l10n.language,
                  valueText: _getLanguageText(settings.language, l10n),
                  onTap: () async {
                    final selected = await showLanguageDialog(
                      context: context,
                      currentValue: _toLanguageOption(settings.language),
                      title: l10n.language,
                      labelFor: (option) {
                        switch (option) {
                          case LanguageOption.system: return l10n.system;
                          case LanguageOption.en: return l10n.english;
                          case LanguageOption.ru: return l10n.russian;
                        }
                      },
                    );
                    if (selected != null) {
                      await settingsProvider.updateLanguage(selected.name);
                    }
                  },
                ),
              ],
            ),
            OnlySmartSettingsSection(
              title: l10n.general,
              children: [
                OnlySmartSettingsTile(
                  icon: Icons.music_note,
                  title: l10n.referencePitch,
                  subtitle: '${settings.referencePitch.toInt()} Hz',
                  onTap: () => _showReferencePitchDialog(context, settingsProvider),
                ),
                Consumer<TunerProvider>(
                  builder: (context, tuner, _) {
                    return OnlySmartSettingsSwitch(
                      icon: Icons.vibration,
                      title: l10n.hapticFeedback,
                      subtitle: l10n.hapticFeedbackSubtitle,
                      value: tuner.hapticEnabled,
                      onChanged: (value) => tuner.setHapticEnabled(value),
                    );
                  },
                ),
              ],
            ),
            OnlySmartAboutSection(
              appName: l10n.appName,
              aboutTitle: l10n.about,
              showBuildNumber: true,
            ),
          ],
        );
      },
    );
  }

  String _getThemeModeText(String mode, AppLocalizations l10n) {
    switch (mode) {
      case 'light':
        return l10n.light;
      case 'dark':
        return l10n.dark;
      default:
        return l10n.system;
    }
  }

  String _getLanguageText(String language, AppLocalizations l10n) {
    switch (language) {
      case 'system':
        return l10n.system;
      case 'ru':
        return l10n.russian;
      default:
        return l10n.english;
    }
  }

  ThemeModeOption _toThemeModeOption(String mode) {
    switch (mode) {
      case 'light':
        return ThemeModeOption.light;
      case 'dark':
        return ThemeModeOption.dark;
      default:
        return ThemeModeOption.system;
    }
  }

  LanguageOption _toLanguageOption(String language) {
    switch (language) {
      case 'ru':
        return LanguageOption.ru;
      default:
        return LanguageOption.en;
    }
  }

  void _showReferencePitchDialog(BuildContext context, SettingsProvider provider) {
    double tempPitch = provider.settings.referencePitch;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.referencePitch),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${tempPitch.toInt()} Hz',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Slider(
                  value: tempPitch,
                  min: 430,
                  max: 450,
                  divisions: 20,
                  label: '${tempPitch.toInt()} Hz',
                  onChanged: (value) {
                    setState(() {
                      tempPitch = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.deny),
          ),
          FilledButton(
            onPressed: () {
              provider.updateReferencePitch(tempPitch);
              Navigator.pop(dialogContext);
            },
            child: Text(AppLocalizations.of(context)!.grant),
          ),
        ],
      ),
    );
  }
}
