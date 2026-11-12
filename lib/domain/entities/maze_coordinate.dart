import 'package:meta/meta.dart';

/// Неизменяемый Value Object для представления координат в лабиринте.
@immutable
final class MazeCoordinate {
  /// Координата по горизонтали (столбец, от 0 до 59).
  final int x;

  /// Координата по вертикали (строка, от 0 до 59).
  final int y;

  /// Создает координаты ячейки с валидацией границ сетки.
  const MazeCoordinate(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MazeCoordinate &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'MazeCoordinate(x: $x, y: $y)';
}

