// Assignment 01: Calculator App
// CSC 4360 - Mobile Application Development
// Howard Fletcher - 002749646
//
// Core: digits 0-9, +, -, x, /, display, responsive layout,
// two-operand calculation flow.
// Selected undergraduate features:
//   1. Clear / All Clear  (AC resets all state, C clears current entry)
//   2. Error handling     (division by zero, incomplete input, recovery)
//   3. Sign toggle        (correct for zero, empty input, negatives)

import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

/// Root widget. Stateless because the app-level configuration never changes;
/// all mutable calculator state lives in [CalculatorScreen].
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

/// The calculation phases the UI can be in. Keeping an explicit phase
/// avoids ambiguous combinations of booleans.
enum CalcPhase { enteringFirst, enteringSecond, showingResult, error }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ---- Authoritative state -------------------------------------------------
  String _currentEntry = ''; // digits the user is typing right now
  double? _firstOperand; // stored operand after an operator is chosen
  String? _pendingOperator; // '+', '-', 'x', '/'
  CalcPhase _phase = CalcPhase.enteringFirst;
  String _errorMessage = '';

  // ---- Derived display (never stored separately, so it cannot drift) ------
  String get _display {
    if (_phase == CalcPhase.error) return _errorMessage;
    if (_currentEntry.isNotEmpty) return _currentEntry;
    if (_phase == CalcPhase.enteringSecond && _firstOperand != null) {
      return _format(_firstOperand!);
    }
    return '0';
  }

  String get _expressionLabel {
    if (_firstOperand == null || _pendingOperator == null) return '';
    return '${_format(_firstOperand!)} $_pendingOperator';
  }

  /// Formats results so integers show without a trailing ".0".
  String _format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.round().toString();
    }
    return value.toString();
  }

  // ---- Input handlers ------------------------------------------------------

  void _onDigit(String digit) {
    setState(() {
      if (_phase == CalcPhase.error) _resetAll();
      if (_phase == CalcPhase.showingResult) {
        // Starting a new number after a result begins a fresh calculation.
        _resetAll();
      }
      if (_currentEntry == '0') _currentEntry = '';
      if (_currentEntry == '-0') _currentEntry = '-';
      if (_currentEntry.replaceFirst('-', '').length < 12) {
        _currentEntry += digit;
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      if (_phase == CalcPhase.error) {
        _resetAll();
        return;
      }
      if (_phase == CalcPhase.showingResult && _currentEntry.isNotEmpty) {
        // Chain off the previous result: result becomes the first operand.
        _firstOperand = double.parse(_currentEntry);
        _currentEntry = '';
        _pendingOperator = op;
        _phase = CalcPhase.enteringSecond;
        return;
      }
      if (_currentEntry.isNotEmpty && _currentEntry != '-') {
        if (_firstOperand != null && _pendingOperator != null) {
          // User typed "a op b op" -> evaluate first, then chain.
          final result = _evaluate();
          if (result == null) return; // error state already set
          _firstOperand = result;
        } else {
          _firstOperand = double.parse(_currentEntry);
        }
        _currentEntry = '';
      }
      if (_firstOperand != null) {
        // Pressing an operator with no entry simply replaces the operator
        // (lets the user change their mind).
        _pendingOperator = op;
        _phase = CalcPhase.enteringSecond;
      } else {
        // Operator pressed with nothing entered at all: incomplete input.
        _setError('Enter a number first');
      }
    });
  }

  void _onEquals() {
    setState(() {
      if (_phase == CalcPhase.error) {
        _resetAll();
        return;
      }
      if (_firstOperand == null || _pendingOperator == null) {
        _setError('Incomplete expression');
        return;
      }
      if (_currentEntry.isEmpty || _currentEntry == '-') {
        _setError('Enter the second number');
        return;
      }
      final result = _evaluate();
      if (result == null) return; // error state already set
      _currentEntry = _format(result);
      _firstOperand = null;
      _pendingOperator = null;
      _phase = CalcPhase.showingResult;
    });
  }

  /// Applies the pending operator. Returns null and enters the error
  /// phase when the calculation is invalid (division by zero).
  double? _evaluate() {
    final a = _firstOperand!;
    final b = double.parse(_currentEntry);
    switch (_pendingOperator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case 'x':
        return a * b;
      case '/':
        if (b == 0) {
          _setError('Cannot divide by zero');
          return null;
        }
        return a / b;
    }
    return null;
  }

  // ---- Feature 1: Clear / All Clear ---------------------------------------

  /// AC: resets every piece of calculator state.
  void _onAllClear() => setState(_resetAll);

  /// C: clears only the current entry, keeping the stored operand/operator.
  void _onClearEntry() {
    setState(() {
      if (_phase == CalcPhase.error || _phase == CalcPhase.showingResult) {
        _resetAll();
      } else {
        _currentEntry = '';
      }
    });
  }

  void _resetAll() {
    _currentEntry = '';
    _firstOperand = null;
    _pendingOperator = null;
    _errorMessage = '';
    _phase = CalcPhase.enteringFirst;
  }

  // ---- Feature 2: Error handling ------------------------------------------

  void _setError(String message) {
    _currentEntry = '';
    _firstOperand = null;
    _pendingOperator = null;
    _errorMessage = message;
    _phase = CalcPhase.error;
  }

  // ---- Feature 3: Sign toggle ----------------------------------------------

  void _onToggleSign() {
    setState(() {
      if (_phase == CalcPhase.error) {
        _resetAll();
        return;
      }
      // Empty input or zero: toggling the sign of nothing/zero stays "0".
      if (_currentEntry.isEmpty ||
          _currentEntry == '0' ||
          _currentEntry == '-0') {
        return;
      }
      _currentEntry = _currentEntry.startsWith('-')
          ? _currentEntry.substring(1)
          : '-$_currentEntry';
    });
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isError = _phase == CalcPhase.error;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expressionLabel,
                      style: TextStyle(
                        fontSize: 22,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _display,
                        key: const Key('display'),
                        semanticsLabel: isError
                            ? 'Error: $_display'
                            : 'Display: $_display',
                        style: TextStyle(
                          fontSize: isError ? 32 : 56,
                          fontWeight: FontWeight.w500,
                          color: isError ? scheme.error : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Button grid
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _row([
                      _btn('AC', onTap: _onAllClear, kind: _Kind.function),
                      _btn('C', onTap: _onClearEntry, kind: _Kind.function),
                      _btn('+/-', onTap: _onToggleSign, kind: _Kind.function),
                      _btn('/',
                          onTap: () => _onOperator('/'), kind: _Kind.operator),
                    ]),
                    _row([
                      _btn('7', onTap: () => _onDigit('7')),
                      _btn('8', onTap: () => _onDigit('8')),
                      _btn('9', onTap: () => _onDigit('9')),
                      _btn('x',
                          onTap: () => _onOperator('x'), kind: _Kind.operator),
                    ]),
                    _row([
                      _btn('4', onTap: () => _onDigit('4')),
                      _btn('5', onTap: () => _onDigit('5')),
                      _btn('6', onTap: () => _onDigit('6')),
                      _btn('-',
                          onTap: () => _onOperator('-'), kind: _Kind.operator),
                    ]),
                    _row([
                      _btn('1', onTap: () => _onDigit('1')),
                      _btn('2', onTap: () => _onDigit('2')),
                      _btn('3', onTap: () => _onDigit('3')),
                      _btn('+',
                          onTap: () => _onOperator('+'), kind: _Kind.operator),
                    ]),
                    _row([
                      _btn('0', onTap: () => _onDigit('0'), flex: 2),
                      const Spacer(),
                      _btn('=', onTap: _onEquals, kind: _Kind.equals),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) =>
      Expanded(child: Row(children: children));

  Widget _btn(String label,
      {required VoidCallback onTap, _Kind kind = _Kind.digit, int flex = 1}) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      _Kind.digit => (scheme.surfaceContainerHigh, scheme.onSurface),
      _Kind.function => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer
        ),
      _Kind.operator => (scheme.primaryContainer, scheme.onPrimaryContainer),
      _Kind.equals => (scheme.primary, scheme.onPrimary),
    };
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            key: Key('btn-$label'),
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Kind { digit, function, operator, equals }
