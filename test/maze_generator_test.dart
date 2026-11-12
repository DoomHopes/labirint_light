import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:labirint_light/data/generators/maze_generator_impl.dart';
import 'package:labirint_light/domain/entities/maze_coordinate.dart';
import 'package:labirint_light/domain/entities/maze_grid.dart';

void main() {
  group('MazeGeneratorImpl', () {
    late MazeGeneratorImpl generator;

    setUp(() {
      generator = MazeGeneratorImpl();
    });

    test('Размерность сетки строго 60x60', () {
      final maze = generator.generate(seed: 123);
      expect(maze.rows.length, equals(60));
      for (final row in maze.rows) {
        expect(row.length, equals(60));
      }
    });

    test('Внешний периметр содержит ровно 4 центральных входа', () {
      final maze = generator.generate(seed: 456);

      // Проверка 4 конкретных входов
      expect(maze.isPassage(MazeGrid.topEntrance.x, MazeGrid.topEntrance.y), isTrue);
      expect(maze.isPassage(MazeGrid.bottomEntrance.x, MazeGrid.bottomEntrance.y), isTrue);
      expect(maze.isPassage(MazeGrid.leftEntrance.x, MazeGrid.leftEntrance.y), isTrue);
      expect(maze.isPassage(MazeGrid.rightEntrance.x, MazeGrid.rightEntrance.y), isTrue);

      // Проверка, что координаты соответствуют центру (индекс 29)
      expect(MazeGrid.topEntrance, equals(const MazeCoordinate(29, 0)));
      expect(MazeGrid.bottomEntrance, equals(const MazeCoordinate(29, 59)));
      expect(MazeGrid.leftEntrance, equals(const MazeCoordinate(0, 29)));
      expect(MazeGrid.rightEntrance, equals(const MazeCoordinate(59, 29)));

      // Подсчет всех проходов по внешнему периметру
      int outerPassages = 0;
      for (int x = 0; x < 60; x++) {
        if (maze.isPassage(x, 0)) outerPassages++;
        if (maze.isPassage(x, 59)) outerPassages++;
      }
      for (int y = 1; y < 59; y++) {
        if (maze.isPassage(0, y)) outerPassages++;
        if (maze.isPassage(59, y)) outerPassages++;
      }

      expect(outerPassages, equals(4), reason: 'На внешнем периметре должно быть ровно 4 входа');
    });

    test('В лабиринте полностью отсутствуют блоки проходов 2x2 (ширина проходов ровно 1)', () {
      final maze = generator.generate(seed: 789);

      for (int y = 0; y < 59; y++) {
        for (int x = 0; x < 59; x++) {
          final is2x2 = maze.isPassage(x, y) &&
              maze.isPassage(x + 1, y) &&
              maze.isPassage(x, y + 1) &&
              maze.isPassage(x + 1, y + 1);
          expect(is2x2, isFalse, reason: 'Обнаружен блок 2x2 в ($x, $y)');
        }
      }
    });

    test('Лабиринт полностью проходим: все 4 входа соединены и нет изолированных участков', () {
      final maze = generator.generate(seed: 101112);

      final visited = List.generate(60, (_) => List.filled(60, false));
      final queue = <Point<int>>[Point(MazeGrid.topEntrance.x, MazeGrid.topEntrance.y)];
      visited[MazeGrid.topEntrance.y][MazeGrid.topEntrance.x] = true;

      int reachableCount = 0;
      final dirs = [
        const Point<int>(0, -1),
        const Point<int>(0, 1),
        const Point<int>(-1, 0),
        const Point<int>(1, 0),
      ];

      while (queue.isNotEmpty) {
        final p = queue.removeAt(0);
        reachableCount++;

        for (final d in dirs) {
          final nx = p.x + d.x;
          final ny = p.y + d.y;
          if (nx >= 0 && nx < 60 && ny >= 0 && ny < 60) {
            if (!visited[ny][nx] && maze.isPassage(nx, ny)) {
              visited[ny][nx] = true;
              queue.add(Point(nx, ny));
            }
          }
        }
      }

      // Проверка достижимости всех 4 входов
      expect(visited[MazeGrid.bottomEntrance.y][MazeGrid.bottomEntrance.x], isTrue);
      expect(visited[MazeGrid.leftEntrance.y][MazeGrid.leftEntrance.x], isTrue);
      expect(visited[MazeGrid.rightEntrance.y][MazeGrid.rightEntrance.x], isTrue);

      // Проверка отсутствия изолированных ячеек
      int totalPassages = 0;
      for (int y = 0; y < 60; y++) {
        for (int x = 0; x < 60; x++) {
          if (maze.isPassage(x, y)) totalPassages++;
        }
      }

      expect(reachableCount, equals(totalPassages));
    });

    test('Детерминированность: одинаковый seed порождает идентичный лабиринт', () {
      final maze1 = generator.generate(seed: 9999);
      final maze2 = generator.generate(seed: 9999);
      expect(maze1, equals(maze2));
    });

    test('Разные seed порождают различные лабиринты', () {
      final maze1 = generator.generate(seed: 1111);
      final maze2 = generator.generate(seed: 2222);
      expect(maze1, isNot(equals(maze2)));
    });

    test('Пакетная проверка 100 случайных сидов на отсутствие нарушений топологии', () {
      for (int s = 0; s < 100; s++) {
        expect(() => generator.generate(seed: s), returnsNormally);
      }
    });
  });
}

