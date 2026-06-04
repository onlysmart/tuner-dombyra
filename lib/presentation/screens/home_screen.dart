import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuner_dombyra/localization/app_localizations.dart';
import 'package:tuner_dombyra/presentation/providers/settings_provider.dart';
import 'package:tuner_dombyra/presentation/providers/tuner_provider.dart';
import 'package:tuner_dombyra/presentation/widgets/frequency_meter.dart';
import 'package:tuner_dombyra/presentation/widgets/note_display.dart';
import 'package:tuner_dombyra/presentation/widgets/tuning_headstock.dart';
import 'package:tuner_dombyra/presentation/screens/settings_screen.dart';
import 'package:tuner_dombyra/domain/models/app_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  TunerProvider? _tuner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTuner();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _retryListening();
    }
  }

  Future<void> _retryListening() async {
    if (!mounted) return;
    final tuner = _tuner;
    if (tuner == null) return;
    for (var i = 0; i < 3; i++) {
      tuner.stopListening();
      await Future.delayed(const Duration(milliseconds: 100));
      await tuner.startListening();
      await Future.delayed(Duration(milliseconds: 500 + i * 500));
      if (tuner.isListening) return;
    }
  }

  void _initTuner() {
    final settings = context.read<SettingsProvider>().settings;
    final tuner = context.read<TunerProvider>();
    _tuner = tuner;

    tuner.setReferencePitch(settings.referencePitch);
    tuner.setTuningMode(
      mode: settings.tuningMode,
      noteNames: tuningNoteNames(settings.tuningMode),
    );

    tuner.startListening();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>().settings;
    final tuner = context.watch<TunerProvider>();

    final hasInput = tuner.accuracy != PitchAccuracy.noInput;
    final isMuted = !tuner.isListening;
    final colorScheme = Theme.of(context).colorScheme;

    String instructionText;
    Color instructionColor;

    if (isMuted) {
      instructionText = l10n.enableMicrophone.toUpperCase();
      instructionColor = colorScheme.primary;
    } else if (!hasInput) {
      instructionText = l10n.playString.toUpperCase();
      instructionColor = colorScheme.primary;
    } else if (tuner.accuracy == PitchAccuracy.inTune) {
      instructionText = l10n.inTune.toUpperCase();
      instructionColor = const Color(0xFF8CC63F);
    } else if (tuner.accuracy == PitchAccuracy.sharp) {
      instructionText = l10n.tooSharp.toUpperCase();
      instructionColor = colorScheme.error;
    } else {
      instructionText = l10n.tooFlat.toUpperCase();
      instructionColor = colorScheme.primary;
    }

    final tuningMode = settings.tuningMode;
    final octaves = tuningOctaves(tuningMode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: Icon(
              tuner.isListening ? Icons.mic : Icons.mic_off,
              color: isMuted ? colorScheme.primary : null,
            ),
            onPressed: () {
              if (tuner.isListening) {
                tuner.stopListening();
              } else {
                tuner.startListening();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            if (isLandscape) {
              return _buildLandscapeLayout(l10n, settings, tuner, hasInput, isMuted, instructionText, instructionColor, octaves);
            }
            return _buildPortraitLayout(l10n, settings, tuner, hasInput, isMuted, instructionText, instructionColor, octaves);
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    AppLocalizations l10n,
    AppSettings settings,
    TunerProvider tuner,
    bool hasInput,
    bool isMuted,
    String instructionText,
    Color instructionColor,
    List<int> octaves,
  ) {
    final tuningMode = settings.tuningMode;
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          instructionText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: instructionColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FrequencyMeter(
            cents: tuner.centsDeviation,
            targetFrequency: tuner.targetFrequency,
            isActive: hasInput,
            isMuted: isMuted,
          ),
        ),
        const SizedBox(height: 16),
        NoteDisplay(
          noteName: hasInput
              ? tuningNoteNames(tuningMode)[tuner.detectedStringIndex]
              : l10n.playString,
          octave: tuner.detectedStringIndex >= 0 && tuner.detectedStringIndex < octaves.length
              ? octaves[tuner.detectedStringIndex].toString()
              : '',
          frequency: tuner.detectedFrequency,
          targetFrequency: tuner.targetFrequency,
          isActive: hasInput,
          isMuted: isMuted,
        ),
        const Spacer(),
        SizedBox(
          width: 180,
          height: 200,
          child: TuningHeadstock(
            noteNames: tuningNoteNames(tuningMode),
            activeStringIndex: tuner.detectedStringIndex,
            cents: tuner.centsDeviation,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    AppLocalizations l10n,
    AppSettings settings,
    TunerProvider tuner,
    bool hasInput,
    bool isMuted,
    String instructionText,
    Color instructionColor,
    List<int> octaves,
  ) {
    final tuningMode = settings.tuningMode;
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                instructionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: instructionColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FrequencyMeter(
                  cents: tuner.centsDeviation,
                  targetFrequency: tuner.targetFrequency,
                  isActive: hasInput,
                  isMuted: isMuted,
                ),
              ),
              const SizedBox(height: 12),
              NoteDisplay(
                noteName: hasInput
                    ? tuningNoteNames(tuningMode)[tuner.detectedStringIndex]
                    : l10n.playString,
                octave: tuner.detectedStringIndex >= 0 && tuner.detectedStringIndex < octaves.length
                    ? octaves[tuner.detectedStringIndex].toString()
                    : '',
                frequency: tuner.detectedFrequency,
                targetFrequency: tuner.targetFrequency,
                isActive: hasInput,
                isMuted: isMuted,
              ),
              const Spacer(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 250,
            child: TuningHeadstock(
              noteNames: tuningNoteNames(tuningMode),
              activeStringIndex: tuner.detectedStringIndex,
              cents: tuner.centsDeviation,
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
