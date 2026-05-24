import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override String get appName => 'Guitar Tuner';
  @override String get settings => 'Settings';
  @override String get appearance => 'Appearance';
  @override String get themeMode => 'Theme';
  @override String get system => 'System';
  @override String get light => 'Light';
  @override String get dark => 'Dark';
  @override String get language => 'Language';
  @override String get english => 'English';
  @override String get russian => 'Russian';
  @override String get general => 'General';
  @override String get referencePitch => 'Reference Pitch (A4)';
  @override String get referencePitchSubtitle => 'Standard: 440 Hz';
  @override String get tuningMode => 'Tuning Mode';
  @override String get standardTuning => 'Standard';
  @override String get dropD => 'Drop D';
  @override String get halfStepDown => 'Half Step Down';
  @override String get fullStepDown => 'Full Step Down';
  @override String get playString => 'Play a string';
  @override String get tooNoisy => 'Too noisy';
  @override String get playLouder => 'Play louder';
  @override String get inTune => 'In tune!';
  @override String get tooSharp => 'Too sharp';
  @override String get tooFlat => 'Too flat';
  @override String get hz => 'Hz';
  @override String targetHz(String hz) => 'Target: $hz Hz';
  @override String get microphonePermissionTitle => 'Microphone Access';
  @override String get microphonePermissionMessage => 'Guitar Tuner needs microphone access.';
  @override String get grant => 'Grant';
  @override String get deny => 'Deny';
  @override String get about => 'About';
  @override String get version => 'Version';
  @override String get stringsEADGBE => 'E A D G B E';
  @override String get stringsEADGBEDropD => 'D A D G B E (Drop D)';
  @override String get stringsEbAbDbGbBbEb => 'Eb Ab Db Gb Bb Eb';
  @override String get stringsDGCFAD => 'D G C F A D';
  @override String get hapticFeedback => 'Haptic Feedback';
  @override String get hapticFeedbackSubtitle => 'Vibrate when in tune';
}
