// Widget tests for the Calculator App.
// CSC 4360 - Howard Fletcher - 002749646
//
// These tests exercise the core two-operand flow plus the three selected
// undergraduate features (clear/AC, error handling, sign toggle) and the
// edge cases called out in the assignment's "Think critically" section.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  // Pumps the app and returns a helper that taps a labeled button.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.byKey(Key('btn-$label')));
    await tester.pump();
  }

  String display(WidgetTester tester) {
    final text = tester.widget<Text>(find.byKey(const Key('display')));
    return text.data!;
  }

  group('core arithmetic', () {
    testWidgets('addition 8 + 7 = 15', (tester) async {
      await pumpApp(tester);
      await tap(tester, '8');
      await tap(tester, '+');
      await tap(tester, '7');
      await tap(tester, '=');
      expect(display(tester), '15');
    });

    testWidgets('subtraction 9 - 14 = -5', (tester) async {
      await pumpApp(tester);
      await tap(tester, '9');
      await tap(tester, '-');
      await tap(tester, '1');
      await tap(tester, '4');
      await tap(tester, '=');
      expect(display(tester), '-5');
    });

    testWidgets('multiplication 6 x 0 = 0', (tester) async {
      await pumpApp(tester);
      await tap(tester, '6');
      await tap(tester, 'x');
      await tap(tester, '0');
      await tap(tester, '=');
      expect(display(tester), '0');
    });

    testWidgets('division 8 / 2 = 4', (tester) async {
      await pumpApp(tester);
      await tap(tester, '8');
      await tap(tester, '/');
      await tap(tester, '2');
      await tap(tester, '=');
      expect(display(tester), '4');
    });
  });

  group('error handling feature', () {
    testWidgets('division by zero shows a recoverable message',
        (tester) async {
      await pumpApp(tester);
      await tap(tester, '8');
      await tap(tester, '/');
      await tap(tester, '0');
      await tap(tester, '=');
      expect(display(tester), 'Cannot divide by zero');
      // Recovery: typing a digit starts fresh.
      await tap(tester, '5');
      expect(display(tester), '5');
    });

    testWidgets('equals before a second operand is rejected', (tester) async {
      await pumpApp(tester);
      await tap(tester, '8');
      await tap(tester, '+');
      await tap(tester, '=');
      expect(display(tester), 'Enter the second number');
    });

    testWidgets('operator with no first number is rejected', (tester) async {
      await pumpApp(tester);
      await tap(tester, '+');
      expect(display(tester), 'Enter a number first');
    });
  });

  group('clear / all-clear feature', () {
    testWidgets('AC after a cleared calc does not reuse the old operator',
        (tester) async {
      await pumpApp(tester);
      // 2 + 3 = 5
      await tap(tester, '2');
      await tap(tester, '+');
      await tap(tester, '3');
      await tap(tester, '=');
      expect(display(tester), '5');
      // AC, then 4 + 1 = 5 (must not reuse previous operator/result)
      await tap(tester, 'AC');
      expect(display(tester), '0');
      await tap(tester, '4');
      await tap(tester, '+');
      await tap(tester, '1');
      await tap(tester, '=');
      expect(display(tester), '5');
    });

    testWidgets('C clears only the current entry', (tester) async {
      await pumpApp(tester);
      await tap(tester, '9');
      await tap(tester, '9');
      await tap(tester, 'C');
      expect(display(tester), '0');
    });
  });

  group('sign toggle feature', () {
    testWidgets('toggles a typed number and back', (tester) async {
      await pumpApp(tester);
      await tap(tester, '5');
      await tap(tester, '+/-');
      expect(display(tester), '-5');
      await tap(tester, '+/-');
      expect(display(tester), '5');
    });

    testWidgets('toggling empty input stays 0', (tester) async {
      await pumpApp(tester);
      await tap(tester, '+/-');
      expect(display(tester), '0');
    });

    testWidgets('toggling zero stays 0', (tester) async {
      await pumpApp(tester);
      await tap(tester, '0');
      await tap(tester, '+/-');
      expect(display(tester), '0');
    });
  });

  group('chaining and repeated operators', () {
    testWidgets('a op b op evaluates the running total', (tester) async {
      await pumpApp(tester);
      await tap(tester, '2');
      await tap(tester, '+');
      await tap(tester, '3');
      await tap(tester, '+'); // should show running total 5
      expect(display(tester), '5');
      await tap(tester, '4');
      await tap(tester, '=');
      expect(display(tester), '9');
    });

    testWidgets('pressing two operators in a row just changes the operator',
        (tester) async {
      await pumpApp(tester);
      await tap(tester, '6');
      await tap(tester, '+');
      await tap(tester, 'x'); // change mind to multiply
      await tap(tester, '2');
      await tap(tester, '=');
      expect(display(tester), '12');
    });

    testWidgets('entering a number after a result starts a new calculation',
        (tester) async {
      await pumpApp(tester);
      await tap(tester, '8');
      await tap(tester, '+');
      await tap(tester, '7');
      await tap(tester, '=');
      expect(display(tester), '15');
      await tap(tester, '3');
      expect(display(tester), '3'); // not "153"
    });
  });
}
