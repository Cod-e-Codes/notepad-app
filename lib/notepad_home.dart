import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

class NotepadHome extends StatefulWidget {
  const NotepadHome({super.key});

  @override
  NotepadHomeState createState() => NotepadHomeState();
}

class NotepadHomeState extends State<NotepadHome> with TickerProviderStateMixin {
  final notesBox = Hive.box('notes');
  final settingsBox = Hive.box('settings');
  TabController? _tabController;
  final List<TextEditingController> _controllers = [];
  final List<String> _tabNames = [];
  final List<FocusNode> _focusNodes = []; // Add focus nodes for each TextField
  final FocusNode _keyboardFocusNode = FocusNode(); // For listening to keyboard shortcuts

  @override
  void initState() {
    super.initState();
    _addNewTab(); // Start with one tab by default
    _tabController = TabController(length: _tabNames.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _toggleDarkMode() {
    final bool isDarkMode = settingsBox.get('darkMode', defaultValue: false);
    settingsBox.put('darkMode', !isDarkMode);
    setState(() {});
  }

  void _addNewTab() {
    setState(() {
      final TextEditingController controller = TextEditingController();
      final FocusNode focusNode = FocusNode(); // Create a focus node for the new TextField
      _controllers.add(controller);
      _focusNodes.add(focusNode); // Add the focus node to the list
      _tabNames.add('Untitled ${_tabNames.length + 1}');
      _tabController = TabController(length: _tabNames.length, vsync: this);
    });
  }

  Future<void> _openNote() async {
    final String? selectedNote = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Open Note'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notesBox.keys.length,
              itemBuilder: (BuildContext context, int index) {
                final String key = notesBox.keys.elementAt(index) as String;
                return ListTile(
                  title: Text(key),
                  onTap: () => Navigator.pop(context, key),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedNote != null && selectedNote.isNotEmpty) {
      setState(() {
        final TextEditingController controller = TextEditingController();
        controller.text = notesBox.get(selectedNote);
        final FocusNode focusNode = FocusNode(); // Create a focus node for this tab
        _controllers.add(controller);
        _focusNodes.add(focusNode);
        _tabNames.add(selectedNote);
        _tabController = TabController(length: _tabNames.length, vsync: this);
      });
    }
  }

  void _renameTab(int index) async {
    String? newName = await _promptForTabName(index);
    if (mounted && newName != null && newName.isNotEmpty) {
      setState(() {
        _tabNames[index] = newName;
      });
    }
  }

  Future<String?> _promptForTabName(int index) async {
    String tempName = _tabNames[index];
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Tab'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => tempName = value,
            decoration: InputDecoration(hintText: _tabNames[index]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(tempName),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _closeTab(int index) {
    if (_tabNames.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot close the last tab.')),
      );
      return;
    }

    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _focusNodes[index].dispose(); // Dispose of the focus node
      _focusNodes.removeAt(index);
      _tabNames.removeAt(index);
      _tabController = TabController(length: _tabNames.length, vsync: this);

      if (_tabController!.index >= _tabNames.length) {
        _tabController!.index = _tabNames.length - 1;
      }
    });
  }

  void _saveCurrentNote() {
    final currentIndex = _tabController?.index ?? 0;
    notesBox.put(_tabNames[currentIndex], _controllers[currentIndex].text);
  }

  void _cut() {
    final currentIndex = _tabController?.index ?? 0;
    Clipboard.setData(ClipboardData(text: _controllers[currentIndex].text));
    _controllers[currentIndex].clear();
    Navigator.pop(context); // Close drawer
  }

  void _copy() {
    final currentIndex = _tabController?.index ?? 0;
    Clipboard.setData(ClipboardData(text: _controllers[currentIndex].text));
    Navigator.pop(context); // Close drawer
  }

  void _paste() async {
    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    final currentIndex = _tabController?.index ?? 0;

    if (!mounted) return;

    setState(() {
      _controllers[currentIndex].text += clipboardData?.text ?? '';
    });

    Navigator.pop(context); // Close drawer
  }

  void _handleKeyboardShortcuts(KeyEvent event) {
    if (HardwareKeyboard.instance.isControlPressed && event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyN) {
        _addNewTab();
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        _saveCurrentNote();
      }
    }
  }

  void _viewHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use Notepad App'),
        content: const Text(
            '1. Use Ctrl + N to create a new tab.\n'
                '2. Use Ctrl + S to save the current note.\n'
                '3. Use Ctrl + O to open an existing note.\n'
                '4. Use Ctrl + X, Ctrl + C, and Ctrl + V to cut, copy, and paste text.\n'
                '5. Use Ctrl + A to select all text in the current tab.\n'
                '6. Use the edit and close icons on each tab to rename or close them.\n'
                '7. Switch between light and dark mode using the toggle in the top-right corner.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = settingsBox.get('darkMode', defaultValue: false);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyboardShortcuts,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notepad'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.brightness_7 : Icons.brightness_4),
              onPressed: _toggleDarkMode,
            ),
          ],
          bottom: _tabNames.isNotEmpty
              ? TabBar(
            controller: _tabController,
            tabs: List.generate(_tabNames.length, (index) {
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_tabNames[index]),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () => _renameTab(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _closeTab(index),
                    ),
                  ],
                ),
              );
            }),
            isScrollable: true,
          )
              : null,
        ),
        drawer: _buildMenu(),
        body: _tabNames.isNotEmpty
            ? TabBarView(
          controller: _tabController,
          children: List.generate(_controllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index], // Use the focus node for each TextField
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration.collapsed(hintText: 'Start typing...'),
                onChanged: (text) => _saveCurrentNote(),
              ),
            );
          }),
        )
            : const Center(child: Text('No notes open')),
      ),
    );
  }

  // Updated _buildMenuItem to include subtitle for keyboard shortcuts
  ListTile _buildMenuItem(String title, IconData icon, {VoidCallback? onTap, String? shortcut}) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (shortcut != null) Text(shortcut, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      onTap: onTap,
    );
  }

  Drawer _buildMenu() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note_alt, size: 48, color: Colors.white), // Notepad icon
                const SizedBox(height: 16), // Space between the icon and text
                const Text(
                  'Notepad Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text('File'),
            children: [
              _buildMenuItem('New Tab', Icons.add, onTap: _addNewTab, shortcut: 'Ctrl + N'),
              _buildMenuItem('Open', Icons.folder_open, onTap: _openNote, shortcut: 'Ctrl + O'),
              _buildMenuItem('Save', Icons.save, onTap: _saveCurrentNote, shortcut: 'Ctrl + S'),
            ],
          ),
          ExpansionTile(
            title: const Text('Edit'),
            children: [
              _buildMenuItem('Cut', Icons.cut, onTap: _cut, shortcut: 'Ctrl + X'),
              _buildMenuItem('Copy', Icons.copy, onTap: _copy, shortcut: 'Ctrl + C'),
              _buildMenuItem('Paste', Icons.paste, onTap: _paste, shortcut: 'Ctrl + V'),
              _buildMenuItem('Select All', Icons.select_all, onTap: () {
                final currentIndex = _tabController?.index ?? 0;
                _controllers[currentIndex].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _controllers[currentIndex].text.length,
                );
                _focusNodes[currentIndex].requestFocus();
                Navigator.pop(context); // Close drawer
              }, shortcut: 'Ctrl + A'),
            ],
          ),
          ExpansionTile(
            title: const Text('Help'),
            children: [
              _buildMenuItem('View Help', Icons.help_outline, onTap: _viewHelp),
              _buildMenuItem('About Notepad App', Icons.info, onTap: () {
                showAboutDialog(
                  context: context,
                  applicationIcon: const Icon(Icons.note_alt, size: 48), // Notepad icon
                  applicationName: 'Notepad App',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 CodēCodes', // Add your company and copyright
                  children: [
                    const Text('A simple Notepad app built with Flutter.')
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
