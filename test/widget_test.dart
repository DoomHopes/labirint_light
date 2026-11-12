import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labirint_light/main.dart';
import 'package:labirint_light/presentation/screens/maze_screen.dart';

void main() {
  testWidgets('Дымовой тест запуска приложения MazeApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MazeApp(),
      ),
    );

    // Проверяем наличие экрана лабиринта
    expect(find.byType(MazeScreen), findsOneWidget);
    expect(find.text('Лабиринт 60x60 (Recursive Backtracker)'), findsOneWidget);
  });
}
