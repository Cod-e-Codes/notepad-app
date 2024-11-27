
# Notepad App

A lightweight and user-friendly notepad app built with Flutter, leveraging the Hive database for local data storage. It features multiple tabs, light/dark mode, and keyboard shortcuts for enhanced productivity.

## Features
- **Multi-Tab Interface**: Create, rename, and close tabs for organizing your notes.
- **Dark Mode**: Toggle between light and dark themes.
- **Keyboard Shortcuts**: Boost productivity with intuitive shortcuts:
  - `Ctrl + N`: Create a new tab
  - `Ctrl + S`: Save the current note
  - `Ctrl + O`: Open an existing note
  - `Ctrl + X`: Cut text
  - `Ctrl + C`: Copy text
  - `Ctrl + V`: Paste text
  - `Ctrl + A`: Select all text in the current tab
- **Persistent Storage**: Save and retrieve notes locally with Hive.

## How to Use
1. Create a new tab using the `+` button or `Ctrl + N`.
2. Start typing in the text editor. Notes are automatically saved.
3. Rename tabs by clicking the edit icon on the tab.
4. Toggle dark mode using the sun/moon icon in the top-right corner.
5. Access help and about sections from the drawer menu.

## Screenshots
### File Menu
<img src="./screenshot1.png" alt="Home Screen" width="400" />

### Home Screen
<img src="./screenshot2.png" alt="Notes in Dark Mode" width="400" />

### Notes in Dark Mode
<img src="./screenshot3.png" alt="File Menu" width="400" />

## Setup and Installation
1. Clone the repository.
2. Install the required dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## Dependencies
- **Hive**: Lightweight and fast NoSQL database for Flutter.
- **Hive Flutter**: Hive integration for Flutter.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

---

## Created By

This project was created by [CodēCodes](https://www.cod-e-codes.com/).

- Website: [CodēCodes](https://www.cod-e-codes.com/)
- GitHub: [Cod-e-Codes](https://github.com/Cod-e-Codes/)
