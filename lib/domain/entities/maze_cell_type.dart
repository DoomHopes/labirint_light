/// Перечисление типов ячеек лабиринта.
enum MazeCellType {
  /// Стена лабиринта (черная ячейка).
  wall,

  /// Проход лабиринта (белая ячейка).
  passage;

  /// Проверяет, является ли ячейка стеной.
  bool get isWall => this == MazeCellType.wall;

  /// Проверяет, является ли ячейка проходом.
  bool get isPassage => this == MazeCellType.passage;
}

