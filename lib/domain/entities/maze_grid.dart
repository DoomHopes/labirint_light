import 'package:meta/meta.dart';
import 'maze_cell_type.dart';
import 'maze_coordinate.dart';

/// Неизменяемая модель квадратной сетки лабиринта строго 60x60 ячеек.
@immutable
final class MazeGrid {
  /// Строгий размер сетки лабиринта.
  static const int dimension = 60;

  /// Индекс центральной ячейки (0-based: 29 соответствует 30-й ячейке).
  static const int centerIndex = 29;

  /// Координаты четырех центральных входов.
  static const MazeCoordinate topEntrance = MazeCoordinate(centerIndex, 0);
  static const MazeCoordinate bottomEntrance =
      MazeCoordinate(centerIndex, dimension - 1);
  static const MazeCoordinate leftEntrance = MazeCoordinate(0, centerIndex);
  static const MazeCoordinate rightEntrance =
      MazeCoordinate(dimension - 1, centerIndex);

  /// Внутреннее двумерное представление ячеек.
  final List<List<MazeCellType>> _cells;

  /// Основной конструктор с защитным копированием и валидацией размерности.
  MazeGrid(List<List<MazeCellType>> cells)
      : assert(cells.length == dimension, 'Количество строк должно быть ровно $dimension'),
        _cells = List<List<MazeCellType>>.unmodifiable(
          cells.map(
            (row) {
              assert(row.length == dimension, 'Длина каждой строки должна быть ровно $dimension');
              return List<MazeCellType>.unmodifiable(row);
            },
          ),
        );

  /// Фабричный конструктор из целочисленной матрицы (0 = проход, 1 = стена).
  factory MazeGrid.fromRawInts(List<List<int>> raw) {
    if (raw.length != dimension) {
      throw ArgumentError('Ожидается ровно $dimension строк, получено: ${raw.length}');
    }
    final mapped = List.generate(
      dimension,
      (y) {
        final row = raw[y];
        if (row.length != dimension) {
          throw ArgumentError('Строка $y должна содержать ровно $dimension элементов');
        }
        return List.generate(
          dimension,
          (x) => row[x] == 0 ? MazeCellType.passage : MazeCellType.wall,
          growable: false,
        );
      },
      growable: false,
    );
    return MazeGrid(mapped);
  }

  /// Получает тип ячейки по координатам (0..59).
  MazeCellType getCell(int x, int y) {
    if (x < 0 || x >= dimension || y < 0 || y >= dimension) {
      throw RangeError('Координаты ($x, $y) выходят за пределы сетки $dimension x $dimension');
    }
    return _cells[y][x];
  }

  /// Проверяет, является ли ячейка стеной.
  bool isWall(int x, int y) => getCell(x, y).isWall;

  /// Проверяет, является ли ячейка проходом.
  bool isPassage(int x, int y) => getCell(x, y).isPassage;

  /// Проверяет, является ли данная ячейка одним из 4-х входов.
  bool isEntrance(int x, int y) {
    return (x == topEntrance.x && y == topEntrance.y) ||
        (x == bottomEntrance.x && y == bottomEntrance.y) ||
        (x == leftEntrance.x && y == leftEntrance.y) ||
        (x == rightEntrance.x && y == rightEntrance.y);
  }

  /// Список всех 4-х входов.
  List<MazeCoordinate> get entrances => const [
        topEntrance,
        bottomEntrance,
        leftEntrance,
        rightEntrance,
      ];

  /// Предоставляет неизменяемый доступ ко всем строкам лабиринта.
  List<List<MazeCellType>> get rows => _cells;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MazeGrid) return false;
    for (int y = 0; y < dimension; y++) {
      for (int x = 0; x < dimension; x++) {
        if (_cells[y][x] != other._cells[y][x]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int hash = 0;
    for (int y = 0; y < dimension; y++) {
      hash = Object.hash(hash, Object.hashAll(_cells[y]));
    }
    return hash;
  }
}

