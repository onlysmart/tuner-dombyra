# 🎸 Dombyra Tuner — Technical Specification

## 1. 🎯 Goal

Create a dombyra tuner app that uses the device's microphone to detect the pitch of dombyra strings and help users tune their instrument. The app should follow the same UI/UX patterns as other OnlySmart apps.

---

## 2. 📋 Features

### 2.1 Core Features

- **Microphone input** — Capture audio from device microphone
- **Pitch detection** — Real-time detection of fundamental frequency (Hz)
- **Standard tuning** — Support for 6-string dombyra (E2, A2, D3, G3, B3, E4)
- **Visual feedback** — Show whether the string is in tune, flat, or sharp
- **String indicators** — Highlight which string is being played
- **Frequency display** — Show detected Hz value

### 2.2 Tuning Modes

- **Standard dombyra** — E A D G B E
- **Drop D** — D A D G B E
- **Half-step down** — Eb Ab Db Gb Bb Eb
- **Full step down** — D G C F A D

### 2.3 UI Elements

- **Tuning wheel/arc** — Visual indicator showing pitch deviation
- **LED-style string indicators** — 6 LEDs showing which string is active
- **Hz display** — Current detected frequency
- **Target Hz** — Expected frequency for selected string
- **In-tune indicator** — Green glow when correctly tuned

### 2.4 Settings

- **Theme** — Light / Dark / System
- **Language** — EN / RU / System
- **Reference pitch** — A4 = 440Hz (adjustable: 430-450Hz)
- **Transpose** — Allow tuning to other instruments (bass, ukulele preset)

### 2.5 Edge Cases

- No microphone permission → show permission request dialog
- Ambient noise → show "Too noisy" warning
- No sound detected → show "Play a string" prompt
- Very quiet input → show "Play louder" prompt

---

## 3. 🎨 UI/UX Design

### 3.1 Main Screen Layout

```
┌─────────────────────────────┐
│     [Settings] [Theme]     │
│                             │
│     ┌─────┬─────┬─────┐    │
│     │  E  │  A  │  D  │    │  ← String LEDs
│     ├─────┼─────┼─────┤    │
│     │  G  │  B  │  E  │    │
│     └─────┴─────┴─────┘    │
│                             │
│         ◉ ◉ ◉ ◉ ◉ ◉       │  ← Tuning arc (in-tune = green)
│                             │
│           442 Hz            │  ← Detected frequency
│         (440 Hz)            │  ← Target frequency
│                             │
│        ▲ Too sharp          │
│        ▼ Too flat           │
│        ● In tune!           │
│                             │
│   [Standard] [Drop D] ...   │  ← Tuning mode selector
│                             │
└─────────────────────────────┘
```

### 3.2 Visual States

| State | Color | Animation |
|-------|-------|-----------|
| In tune (±5 cents) | Green | Pulse glow |
| Slightly flat (>5 cents) | Yellow-Orange | Arrow down |
| Slightly sharp (<5 cents) | Yellow-Orange | Arrow up |
| Very flat/sharp (>25 cents) | Red | Arrow + shake |
| No input | Gray | Dim |

### 3.3 Design Tokens

- Primary accent: `#1976d2` (blue)
- Success (in-tune): `#4CAF50` (green)
- Warning (close): `#FF9800` (orange)
- Error (off): `#F44336` (red)
- Background: `#FFFFFF` / `#121212`
- Card background: `#F5F5F5` / `#1E1E1E`

---

## 4. 🛠️ Technical Architecture

### 4.1 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  onlysmart_ui:
    path: ../../packages/onlysmart_ui
  flutter_localizations:
    sdk: flutter
  provider: ^6.1.2
  shared_preferences: ^2.3.3
  permission_handler: ^11.3.1
  audio_session: ^0.1.21
  flutter_animate: ^4.5.0
  intl: ^0.20.2
```

### 4.2 Audio Processing

- Use `permission_handler` for microphone permission
- Use native platform channels or `dart:io` for raw audio capture
- FFT analysis for pitch detection (pitch_detector package or custom)
- Sample rate: 44100 Hz
- Buffer size: 4096 samples
- Update rate: 20-30 Hz for UI

### 4.3 State Management

- `ChangeNotifier` with `Provider` pattern (like metronome app)
- Settings stored in `SharedPreferences`

### 4.4 Key Classes

```
lib/
├── main.dart
├── app.dart
├── core/
│   └── theme/
├── data/
│   └── repositories/
├── domain/
│   └── models/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
├── services/
│   └── audio_service.dart
└── l10n/
```

### 4.5 Pitch Detection Algorithm

1. Capture audio buffer
2. Apply FFT to get frequency spectrum
3. Find dominant frequency using autocorrelation or YIN algorithm
4. Map frequency to nearest note (E2-E4 for dombyra)
5. Calculate cents deviation from target
6. Update UI at 30Hz

---

## 5. 📝 Step-by-Step Implementation Plan

### Phase 1: Project Setup
- [ ] Create folder structure
- [ ] Copy and adapt pubspec.yaml from metronome
- [ ] Set up l10n.yaml and ARB files
- [ ] Create basic main.dart with theme/localization scaffold
- [ ] Add placeholder app icon and splash

### Phase 2: UI Foundation
- [ ] Create settings screen with theme/language
- [ ] Build main tuner screen layout
- [ ] Implement string LED indicators (6 circles)
- [ ] Implement tuning mode selector (chips)
- [ ] Add theme provider and language provider

### Phase 3: Audio Core
- [ ] Add microphone permission handling
- [ ] Create audio service for mic input
- [ ] Implement pitch detection algorithm
- [ ] Create tuner engine with note mapping
- [ ] Add reference pitch adjustment (A4 = 440Hz)

### Phase 4: Tuning Display
- [ ] Build tuning arc visualization
- [ ] Implement frequency display widget
- [ ] Show target vs detected Hz
- [ ] Add in-tune/sharp/flat indicators with colors
- [ ] Add animations for visual feedback

### Phase 5: Polish
- [ ] Add "Too noisy" / "Play louder" / "No input" states
- [ ] Tune sensitivity settings
- [ ] Add preset tunings (drop D, half-step, etc.)
- [ ] Haptic feedback when in tune
- [ ] Final theme and localization pass

### Phase 6: Testing & Build
- [ ] Test on iOS simulator and real device
- [ ] Test pitch detection accuracy
- [ ] Build verification
- [ ] Final lint/analyze check

---

## 6. 🎯 Success Criteria

- App detects dombyra string pitch within ±5 cents accuracy
- UI updates at 30Hz for smooth visual feedback
- Works offline (all processing local)
- Follows OnlySmart design language
- Supports EN/RU/System languages
- Supports light/dark/system theme

---

## 7. 📦 Future Expansion (tuner-* family)

- `tuner-ukulele` — 4-string ukulele tuner
- `tuner-bass` — 4-string bass dombyra tuner
- `tuner-violin` — Violin tuner
- `tuner-chromatic` — Chromatic tuner for any instrument