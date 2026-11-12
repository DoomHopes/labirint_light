import 'dart:typed_data';
import '../entities/maze_grid.dart';

/// Абстрактный контракт экспортера лабиринта в схематику мода Litematica (.litematic).
abstract interface class IMazeLitematicExporter {
  /// Экспортирует лабиринт [maze] в нативный формат Litematica (.litematic),
  /// сжатый алгоритмом GZip.
  ///
  /// Создается строго 1 слой (высота 1 блок):
  /// - Белые ячейки (проходы) экспортируются как воздух (`minecraft:air`).
  /// - Черные ячейки (стены) экспортируются как блоки [wallBlock] (по умолчанию `minecraft:deepslate_bricks`).
  Uint8List toLitematic(
    MazeGrid maze, {
    String wallBlock = 'minecraft:deepslate_bricks',
    String author = 'Antigravity',
  });
}

