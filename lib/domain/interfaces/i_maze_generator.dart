import '../entities/maze_grid.dart';

/// Абстрактный интерфейс генератора лабиринтов.
abstract interface class IMazeGenerator {
  /// Генерирует лабиринт сетки 60x60.
  ///
  /// При передаче [seed] генератор детерминированно воспроизводит одинаковую топологию.
  MazeGrid generate({int? seed});
}

