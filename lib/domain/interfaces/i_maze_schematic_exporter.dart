import 'dart:typed_data';
import '../entities/maze_grid.dart';

/// Абстрактный контракт экспортера лабиринта в схематику WorldEdit (.schem).
abstract interface class IMazeSchematicExporter {
  /// Экспортирует лабиринт [maze] в бинарный формат Sponge Schematic v2,
  /// сжатый алгоритмом GZip.
  ///
  /// Создается строго 1 слой (Y = 1):
  /// - Белые ячейки (проходы) экспортируются как воздух (`minecraft:air`).
  /// - Черные ячейки (стены) экспортируются как блоки [wallBlock] (по умолчанию `minecraft:deepslate_bricks`).
  Uint8List toSchematic(
    MazeGrid maze, {
    String wallBlock = 'minecraft:deepslate_bricks',
  });
}

