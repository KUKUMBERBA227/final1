import 'dart:io';

/// Since the request is for a terminal-like interface but restricted to pure Dart 
/// (non-Flutter/non-Android-native), this implementation provides a terminal-style
/// CLI application shell. 
/// 
/// Note: To function as a real Android Launcher, one must use the Android SDK 
/// (Java/Kotlin) and an Intent-filter for "android.intent.category.HOME".
/// This Dart program acts as the business logic emulator for that interface.

class TerminalLauncher {
  final List<String> _installedApps = [
    'Settings',
    'Browser',
    'Camera',
    'Gallery',
    'Messages',
    'Phone',
    'Calculator'
  ];

  bool _isRunning = true;

  void start() {
    print('--- TERMINAL LAUNCHER INITIALIZED ---');
    print('Type "apps" to see installed applications.');
    print('Type "exit" to close the terminal.');

    while (_isRunning) {
      stdout.write('root@android:~# ');
      final input = stdin.readLineSync()?.toLowerCase().trim();

      switch (input) {
        case 'apps':
          _showApps();
          break;
        case 'exit':
          _isRunning = false;
          print('Exiting terminal...');
          break;
        case '':
          continue;
        default:
          print('Command not found: $input');
      }
    }
  }

  void _showApps() {
    print('\n[APPLICATIONS]');
    for (var i = 0; i < _installedApps.length; i++) {
      print('${i + 1}. ${_installedApps[i]}');
    }
    print('');
  }
}

void main(List<String> arguments) {
  try {
    final terminal = TerminalLauncher();
    terminal.start();
  } catch (e) {
    print('Critical Error: $e');
    exit(1);
  }
}
