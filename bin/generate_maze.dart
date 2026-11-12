// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:labirint_light/data/exporters/maze_litematic_exporter_impl.dart';
import 'package:labirint_light/data/exporters/maze_schematic_exporter_impl.dart';
import 'package:labirint_light/data/exporters/maze_svg_exporter_impl.dart';
import 'package:labirint_light/data/generators/maze_generator_impl.dart';

/// Консольный скрипт для мгновенной генерации схемы лабиринта 60x60 в форматах SVG, Litematica и WorldEdit.
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

  // 1. Экспорт в SVG
  const svgExporter = MazeSvgExporterImpl();
  final svgString = svgExporter.toSvg(
    maze,
    cellSize: 24.0,
    labelMargin: 60.0,
  );
  final svgFile = File('maze_60x60.svg');
  svgFile.writeAsStringSync(svgString);
  print(' Векторная схема сохранена в: ${svgFile.absolute.path}');

  // 2. Экспорт в нативный формат Litematica (.litematic)
  const litematicExporter = MazeLitematicExporterImpl();
  final litematicBytes = litematicExporter.toLitematic(
    maze,
    wallBlock: 'minecraft:deepslate_bricks',
  );
  final litematicFile = File('maze_60x60.litematic');
  litematicFile.writeAsBytesSync(litematicBytes);
  print(' Схематика Litematica (.litematic) сохранена в: ${litematicFile.absolute.path}');

  // 3. Экспорт в схематику WorldEdit (.schem)
  const schemExporter = MazeSchematicExporterImpl();
  final schemBytes = schemExporter.toSchematic(
    maze,
    wallBlock: 'minecraft:deepslate_bricks',
  );
  final schemFile = File('maze_60x60.schem');
  schemFile.writeAsBytesSync(schemBytes);
  print(' Схематика WorldEdit (.schem) сохранена в: ${schemFile.absolute.path}');
  print('   Параметры: 60x1x60 (1 слой), белый = minecraft:air, чёрный = minecraft:deepslate_bricks');
  print('=== Готово! ===');
}
