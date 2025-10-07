// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alfa_forge/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUpAll(() async {
    // Ensure widgets binding and initialize Supabase before tests
    WidgetsFlutterBinding.ensureInitialized();
    // Mock SharedPreferences for plugin-less test environment
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example-project.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.PLACEHOLDER.SIGNATURE',
    );
  });
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PRIMEApp()));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // App should start without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
