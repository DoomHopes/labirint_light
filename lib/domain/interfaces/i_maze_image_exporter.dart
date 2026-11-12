import 'dart:typed_data';
import '../entities/maze_grid.dart';

/// Абстрактный интерфейс растрового экспортера лабиринта в высоком разрешении.
abstract interface class IMazeImageExporter {
  /// Рендерит лабиринт [maze] в высоком разрешении и возвращает байты изображения в формате PNG.
  ///
  /// [cellSize] — размер ячейки в пикселях (рекомендуется от 30.0 до 60.0 для четкости цифр).
  /// [labelMargin] — отступ по периметру для размещения номеров строк и столбцов 1..60.
  Future<Uint8List> toPng(
    MazeGrid maze, {
    double cellSize = 35.0,
    double labelMargin = 80.0,
  });
}

