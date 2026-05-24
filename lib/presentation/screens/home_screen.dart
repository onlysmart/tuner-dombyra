import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuner_guitar/localization/app_localizations.dart';
import 'package:tuner_guitar/presentation/providers/settings_provider.dart';
import 'package:tuner_guitar/presentation/providers/tuner_provider.dart';
import 'package:tuner_guitar/presentation/widgets/frequency_meter.dart';
import 'package:tuner_guitar/presentation/widgets/note_display.dart';
import 'package:tuner_guitar/presentation/widgets/tuning_headstock.dart';
import 'package:tuner_guitar/presentation/screens/settings_screen.dart';
import 'package:tuner_guitar/domain/models/app_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTuner();
    });
  }

  void _initTuner() {
    final settings = context.read<SettingsProvider>().settings;
    final tuner = context.read<TunerProvider>();

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

    String instructionText;
    Color instructionColor;

    if (!hasInput) {
      instructionText = l10n.playString.toUpperCase();
      instructionColor = Theme.of(context).colorScheme.primary;
    } else if (tuner.accuracy == PitchAccuracy.inTune) {
      instructionText = l10n.inTune.toUpperCase();
      instructionColor = const Color(0xFF8CC63F);
    } else if (tuner.accuracy == PitchAccuracy.sharp) {
      instructionText = l10n.tooSharp.toUpperCase();
      instructionColor = Theme.of(context).colorScheme.error;
    } else {
      instructionText = l10n.tooFlat.toUpperCase();
      instructionColor = Theme.of(context).colorScheme.primary;
    }

    final tuningMode = settings.tuningMode;
    final octaves = tuningOctaves(tuningMode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: Icon(tuner.isListening ? Icons.mic : Icons.mic_off),
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
              return _buildLandscapeLayout(l10n, settings, tuner, hasInput, instructionText, instructionColor, octaves);
            }
            return _buildPortraitLayout(l10n, settings, tuner, hasInput, instructionText, instructionColor, octaves);
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
            isActive: hasInput,
          ),
        ),
        const SizedBox(height: 16),
        NoteDisplay(
          noteName: tuner.detectedStringIndex >= 0
              ? tuningNoteNames(tuningMode)[tuner.detectedStringIndex]
              : '-',
          octave: tuner.detectedStringIndex >= 0 && tuner.detectedStringIndex < octaves.length
              ? octaves[tuner.detectedStringIndex].toString()
              : '',
          frequency: tuner.detectedFrequency,
          isActive: hasInput,
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
        const SizedBox(height: 12),
        _buildTuningModeSelector(settings, tuner, l10n),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    AppLocalizations l10n,
    AppSettings settings,
    TunerProvider tuner,
    bool hasInput,
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
                  isActive: hasInput,
                ),
              ),
              const SizedBox(height: 12),
              NoteDisplay(
                noteName: tuner.detectedStringIndex >= 0
                    ? tuningNoteNames(tuningMode)[tuner.detectedStringIndex]
                    : '-',
                octave: tuner.detectedStringIndex >= 0 && tuner.detectedStringIndex < octaves.length
                    ? octaves[tuner.detectedStringIndex].toString()
                    : '',
                frequency: tuner.detectedFrequency,
                isActive: hasInput,
              ),
              const Spacer(),
              _buildTuningModeSelector(settings, tuner, l10n),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SizedBox(
          width: 150,
          height: 250,
          child: TuningHeadstock(
            noteNames: tuningNoteNames(tuningMode),
            activeStringIndex: tuner.detectedStringIndex,
            cents: tuner.centsDeviation,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTuningModeSelector(AppSettings settings, TunerProvider tuner, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: TuningMode.values.map((mode) {
          final isSelected = settings.tuningMode == mode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_getModeLabel(mode, l10n)),
              selected: isSelected,
              onSelected: (_) {
                context.read<SettingsProvider>().updateTuningMode(mode);
                tuner.setTuningMode(
                  mode: mode,
                  noteNames: tuningNoteNames(mode),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getModeLabel(TuningMode mode, AppLocalizations l10n) {
    switch (mode) {
      case TuningMode.standard:
        return l10n.standardTuning;
      case TuningMode.dropD:
        return l10n.dropD;
      case TuningMode.halfStepDown:
        return l10n.halfStepDown;
      case TuningMode.fullStepDown:
        return l10n.fullStepDown;
    }
  }
}
