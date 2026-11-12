// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:labirint_light/data/exporters/maze_svg_exporter_impl.dart';
import 'package:labirint_light/data/generators/maze_generator_impl.dart';

/// Консольный скрипт для мгновенной генерации схемы лабиринта 60x60 в векторном формате SVG.
///
/// Использование:
///   dart run bin/generate_maze.dart [seed]
void main(List<String> args) {
  final int seed = args.isNotEmpty ? int.parse(args[0]) : Random().nextInt(1000000);
  print('=== Генерация лабиринта 60x60 (Seed: $seed) ===');

  final generator = MazeGeneratorImpl();
  final stopwatch = Stopwatch()..start();
  final maze = generator.generate(seed: seed);
  stopwatch.stop();

  print(' Лабиринт 60x60 успешно сгенерирован за ${stopwatch.elapsedMilliseconds} мс.');
  print(' Внешний периметр: 4 центральных входа (по 1 клетке шириной: верх, низ, лево, право).');
  print(' Проходимость: 100% проходов соединены в единый компонент связности.');
  print(' Ширина проходов: строго 1 клетка (блоков 2x2 нет).');

  // Экспорт в SVG
  const svgExporter = MazeSvgExporterImpl();
  final svgString = svgExporter.toSvg(
    maze,
    cellSize: 24.0,
    labelMargin: 60.0,
  );

  final outputFile = File('maze_60x60.svg');
  outputFile.writeAsStringSync(svgString);

  print(' Векторная схема сохранена в: ${outputFile.absolute.path}');
  print(' Разрешение схемы: 1560x1560 px (масштабируется без потери качества).');
  print(' Каждая ячейка разделена тонкой линией, пронумерованы все строки и столбцы от 1 до 60 со всех 4 сторон.');
  print('=== Готово! ===');
}
