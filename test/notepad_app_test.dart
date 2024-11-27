import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';
import 'package:notepad_app/notepad_home.dart';

void main() {
  setUp(() async {
    // Initialize Hive test environment
    await setUpTestHive();
    await Hive.openBox('settings');
    await Hive.openBox('notes');
  });

  tearDown(() async {
    await Hive.box('settings').close();
    await Hive.box('notes').close();
    await tearDownTestHive();
  });

  testWidgets('Dark mode toggle works correctly in NotepadHome', (WidgetTester tester) async {
    // Build NotepadHome widget
    await tester.pumpWidget(const MaterialApp(home: NotepadHome()));

    // Verify that the app starts in light mode
    expect(find.byIcon(Icons.brightness_4), findsOneWidget);

    // Tap the icon to toggle dark mode
    await tester.tap(find.byIcon(Icons.brightness_4));
    await tester.pumpAndSettle();

    // Verify that dark mode is toggled
    expect(find.byIcon(Icons.brightness_7), findsOneWidget);
  });

  testWidgets('New Note works correctly', (WidgetTester tester) async {
    // Build NotepadHome widget
    await tester.pumpWidget(const MaterialApp(home: NotepadHome()));

    // Enter some text
    await tester.enterText(find.byType(TextField), 'Test note');
    await tester.pumpAndSettle();

    // Open drawer and tap "New"
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    // Verify the note is cleared
    expect(find.text('Test note'), findsNothing);
  });

  testWidgets('Cut, Copy, and Paste work correctly', (WidgetTester tester) async {
    // Build NotepadHome widget
    await tester.pumpWidget(const MaterialApp(home: NotepadHome()));

    // Enter some text
    await tester.enterText(find.byType(TextField), 'Cut Copy Paste Test');
    await tester.pumpAndSettle();

    // Open drawer and tap "Cut"
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cut'));
    await tester.pumpAndSettle();

    // Verify the text is cleared after cut
    expect(find.text('Cut Copy Paste Test'), findsNothing);

    // Paste the content back
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();

    // Verify the text is pasted
    expect(find.text('Cut Copy Paste Test'), findsOneWidget);
  });

  testWidgets('Save Note works correctly', (WidgetTester tester) async {
    // Build NotepadHome widget
    await tester.pumpWidget(const MaterialApp(home: NotepadHome()));

    // Enter some text
    await tester.enterText(find.byType(TextField), 'Test note');
    await tester.pumpAndSettle();

    // Open drawer and tap "Save"
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify the note is saved in Hive
    final notesBox = Hive.box('notes');
    final savedNote = notesBox.get('note');
    expect(savedNote, 'Test note');
  });
}
