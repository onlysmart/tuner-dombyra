import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());
  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static const List<Locale> supportedLocales = [Locale('en'), Locale('ru')];

  String get appName;
  String get settings;
  String get appearance;
  String get themeMode;
  String get system;
  String get light;
  String get dark;
  String get language;
  String get english;
  String get russian;
  String get general;
  String get referencePitch;
  String get referencePitchSubtitle;
  String get tuningMode;
  String get standardTuning;
  String get dropD;
  String get halfStepDown;
  String get fullStepDown;
  String get playString;
  String get tooNoisy;
  String get playLouder;
  String get inTune;
  String get tooSharp;
  String get tooFlat;
  String get hz;
  String targetHz(String hz);
  String get microphonePermissionTitle;
  String get microphonePermissionMessage;
  String get grant;
  String get deny;
  String get about;
  String get version;
  String get stringsEADGBE;
  String get stringsEADGBEDropD;
  String get stringsEbAbDbGbBbEb;
  String get stringsDGCFAD;
  String get hapticFeedback;
  String get hapticFeedbackSubtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }
  @override bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }
  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale".');
}
