# Calculator App — CSC 4360 Assignment 01

**Howard Fletcher — 002749646**
Mobile Application Development · Flutter + Dart

A clean, reliable two-operand calculator built in Flutter.

## Features

### Core
- Number buttons `0`–`9`
- Four operations: `+`, `-`, `x`, `/`
- Readable display for input and results
- Responsive layout (display scales with `FittedBox`, buttons fill a grid)
- Two-operand calculation flow driven entirely from state

### Selected undergraduate features (3 of 6)
1. **Clear / All Clear** — `AC` resets all calculator state; `C` clears only the current entry.
2. **Error handling** — division by zero and incomplete input produce a clear, recoverable on-screen message.
3. **Sign toggle** — `+/-` flips the sign of the current number; behaves correctly for zero and empty input.

## Architecture

All mutable state lives in `_CalculatorScreenState` as four authoritative
fields (`_currentEntry`, `_firstOperand`, `_pendingOperator`, `_phase`). The
visible display is **derived** from that state via a getter rather than stored
separately, so the display can never drift out of sync with the real value.
An explicit `CalcPhase` enum replaces a tangle of booleans.

## Build & run

```bash
flutter pub get
flutter run                 # run on an emulator or device
flutter test                # run the widget test suite (15 tests)
flutter build apk --release # produce the release APK
```

The release APK is written to
`build/app/outputs/flutter-apk/app-release.apk`.

## Tests

`test/widget_test.dart` covers the core arithmetic flow, each selected
feature, and the edge cases from the assignment prompt (division by zero,
equals pressed too early, repeated operators, entering a number after a
result). Run them with `flutter test`.
