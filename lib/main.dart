import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notepad_home.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('notes');

  runApp(const NotepadApp());
}

class NotepadApp extends StatefulWidget {
  const NotepadApp({super.key});

  @override
  NotepadAppState createState() => NotepadAppState();
}

class NotepadAppState extends State<NotepadApp> {
  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, Box box, widget) {
        final bool isDarkMode = box.get('darkMode', defaultValue: false);

        return MaterialApp(
          title: 'Notepad App',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const NotepadHome(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
