// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tercerexamendispomoviles/main.dart';

void main() {
  testWidgets('Air Quality Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app bar title is displayed.
    expect(find.text('Calidad del Aire'), findsOneWidget);

    // Verify that the form card elements are displayed.
    expect(find.text('Datos de Exposición'), findsOneWidget);
    expect(find.text('Seleccione una ciudad'), findsOneWidget);
  });
}

