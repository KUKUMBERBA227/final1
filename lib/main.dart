import 'dart:async';

/// TerminalLauncher acts as a CLI shell that allows users to interact with 
/// a simulated list of installed applications.
/// 
/// Refactored to ensure correct logic and robust command processing.
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

  /// Starts the terminal command loop.
  /// Uses a simulated stream-like interaction for demonstrate purposes.
  Future<void> start() async {
    print('--- TERMINAL LAUNCHER INITIALIZED ---');
    print('Available commands: "apps", "launch <name/index>", "exit"');

    final List<String> demoCommands = [
      'apps',
      'launch 2',
      'launch Settings',
      'launch Unknown',
      'exit'
    ];

    for (final input in demoCommands) {
      if (!_isRunning) break;
      
      print('\nroot@system:~\$ $input');
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 600));

      final parts = input.trim().split(RegExp(r'\s+'));
      if (parts.isEmpty) continue;
      
      final command = parts.first.toLowerCase();

      try {
        switch (command) {
          case 'apps':
            _showApps();
            break;
          case 'launch':
            if (parts.length > 1) {
              await _launchApp(parts.sublist(1).join(' '));
            } else {
              print('Error: Please specify an application name or index.');
            }
            break;
          case 'exit':
            _isRunning = false;
            print('Exiting terminal...');
            break;
          default:
            print('Command not found: "$command". Type "apps" to see the list.');
        }
      } catch (e) {
        print('Error processing command "$command": $e');
      }
    }
  }

  void _showApps() {
    print('\n[INSTALLED APPLICATIONS]');
    for (var i = 0; i < _installedApps.length; i++) {
      print('${i + 1}. ${_installedApps[i]}');
    }
  }

  Future<void> _launchApp(String identifier) async {
    // Attempt to find by index (1-based)
    final index = int.tryParse(identifier);
    String? appName;

    if (index != null) {
      if (index > 0 && index <= _installedApps.length) {
        appName = _installedApps[index - 1];
      }
    } else {
      // Attempt to find by name (case-insensitive)
      final match = _installedApps.where(
        (app) => app.toLowerCase() == identifier.toLowerCase(),
      );
      
      if (match.isNotEmpty) {
        appName = match.first;
      }
    }

    if (appName != null) {
      print('>> Launching $appName...');
      await Future.delayed(const Duration(milliseconds: 500));
      print('>> $appName is now running.');
    } else {
      print('Error: Application "$identifier" could not be found.');
    }
  }
}

/// The main entry point handles command-line arguments as required by Dart.
/// Providing default empty list ensures compatibility with various runners.
Future<void> main([List<String> arguments = const []]) async {
  try {
    final terminal = TerminalLauncher();
    await terminal.start();
  } catch (e, stackTrace) {
    print('A critical system error occurred: $e');
    print(stackTrace);
  }
}
