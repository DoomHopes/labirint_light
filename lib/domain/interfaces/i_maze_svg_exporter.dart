import '../entities/maze_grid.dart';

/// Абстрактный интерфейс векторного экспортера лабиринта в формат SVG.
abstract interface class IMazeSvgExporter {
  /// Генерирует валидную SVG-разметку для переданного лабиринта [maze].
  ///
  /// [cellSize] — размер стороны ячейки в пикселях.
  /// [labelMargin] — отступ по периметру для размещения номеров строк и столбцов 1..60.
  String toSvg(
    MazeGrid maze, {
    double cellSize = 20.0,
    double labelMargin = 60.0,
  });
}

