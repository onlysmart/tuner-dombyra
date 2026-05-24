import 'app_localizations.dart';

class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override String get appName => 'Гитарный тюнер';
  @override String get settings => 'Настройки';
  @override String get appearance => 'Внешний вид';
  @override String get themeMode => 'Тема';
  @override String get system => 'Системная';
  @override String get light => 'Светлая';
  @override String get dark => 'Тёмная';
  @override String get language => 'Язык';
  @override String get english => 'Английский';
  @override String get russian => 'Русский';
  @override String get general => 'Общие';
  @override String get referencePitch => 'Эталонный строй (A4)';
  @override String get referencePitchSubtitle => 'Стандарт: 440 Гц';
  @override String get tuningMode => 'Режим настройки';
  @override String get standardTuning => 'Стандартный';
  @override String get dropD => 'Drop D';
  @override String get halfStepDown => 'На полтоса ниже';
  @override String get fullStepDown => 'На тон ниже';
  @override String get playString => 'Играйте струну';
  @override String get tooNoisy => 'Слишком шумно';
  @override String get playLouder => 'Играйте громче';
  @override String get inTune => 'Настроено!';
  @override String get tooSharp => 'Выше';
  @override String get tooFlat => 'Ниже';
  @override String get hz => 'Гц';
  @override String targetHz(String hz) => 'Цель: $hz Гц';
  @override String get microphonePermissionTitle => 'Доступ к микрофону';
  @override String get microphonePermissionMessage => 'Гитарному тюнеру нужен доступ к микрофону.';
  @override String get grant => 'Разрешить';
  @override String get deny => 'Отклонить';
  @override String get about => 'О приложении';
  @override String get version => 'Версия';
  @override String get stringsEADGBE => 'E A D G B E';
  @override String get stringsEADGBEDropD => 'D A D G B E (Drop D)';
  @override String get stringsEbAbDbGbBbEb => 'Eb Ab Db Gb Bb Eb';
  @override String get stringsDGCFAD => 'D G C F A D';
  @override String get hapticFeedback => 'Тактильный отклик';
  @override String get hapticFeedbackSubtitle => 'Вибрация при точной настройке';
}
