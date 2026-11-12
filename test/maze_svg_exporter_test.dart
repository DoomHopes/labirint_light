import 'package:flutter_test/flutter_test.dart';
import 'package:labirint_light/data/exporters/maze_svg_exporter_impl.dart';
import 'package:labirint_light/data/generators/maze_generator_impl.dart';

void main() {
  group('MazeSvgExporterImpl', () {
    late MazeGeneratorImpl generator;
    late MazeSvgExporterImpl exporter;

    setUp(() {
      generator = MazeGeneratorImpl();
      exporter = const MazeSvgExporterImpl();
    });

    test('Формирует валидную SVG разметку с размерами и стилями', () {
      final maze = generator.generate(seed: 42);
      final svg = exporter.toSvg(maze, cellSize: 20.0, labelMargin: 50.0);

      expect(svg.startsWith('<?xml'), isTrue);
      expect(svg.contains('<svg xmlns="http://www.w3.org/2000/svg"'), isTrue);
      expect(svg.contains('</svg>'), isTrue);

      // Полный размер: 60 * 20 + 2 * 50 = 1300
      expect(svg.contains('width="1300.0"'), isTrue);
      expect(svg.contains('height="1300.0"'), isTrue);
    });

    test('Разметка содержит номера строк и столбцов от 1 до 60', () {
      final maze = generator.generate(seed: 42);
      final svg = exporter.toSvg(maze);

      for (int i = 1; i <= 60; i++) {
        expect(svg.contains('>$i</text>'), isTrue, reason: 'Отсутствует число $i');
      }
    });

    test('Разметка содержит 3600 ячеек (60x60)', () {
      final maze = generator.generate(seed: 42);
      final svg = exporter.toSvg(maze);

      // Проверяем количество тегов <rect в группе cells
      final rectMatches = RegExp(r'<rect x=').allMatches(svg);
      // 3600 ячеек лабиринта
      expect(rectMatches.length, equals(3600));
    });
  });
}

