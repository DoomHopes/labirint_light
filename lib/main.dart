import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'presentation/screens/maze_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MazeApp(),
    ),
  );
}

/// Корневой виджет приложения генерации лабиринтов.
final class MazeApp extends StatelessWidget {
  const MazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Генератор лабиринта 60x60',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
        ),
      ),
      home: const MazeScreen(),
    );
  }
}
