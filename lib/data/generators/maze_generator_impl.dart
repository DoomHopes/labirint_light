import 'dart:math';
import '../../domain/entities/maze_grid.dart';
import '../../domain/interfaces/i_maze_generator.dart';

/// Реализация генератора лабиринта с адаптацией Recursive Backtracker под сетку 60x60.
final class MazeGeneratorImpl implements IMazeGenerator {
  /// Размер сетки.
  static const int _size = MazeGrid.dimension;

  /// Количество базовых комнат по каждой оси.
  static const int _roomCount = 30;

  /// Координаты комнат по оси X (15 слева, 15 справа с переходом в центре 29-30).
  static const List<int> _roomXs = [
    1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29,
    30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58,
  ];

  /// Координаты комнат по оси Y (15 сверху, 15 снизу с переходом в центре 29-30).
  static const List<int> _roomYs = [
    1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29,
    30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58,
  ];

  @override
  MazeGrid generate({int? seed}) {
    final random = seed != null ? Random(seed) : Random();

    // Инициализация сетки стенами: 1 = стена, 0 = проход
    final grid = List.generate(_size, (_) => List.filled(_size, 1));

    // Матрица посещенных комнат
    final visited = List.generate(
      _roomCount,
      (_) => List.filled(_roomCount, false),
    );

    // Стек для обхода в глубину (DFS)
    final stack = <Point<int>>[];

    // Начальная комната: rx = 14 (x = 29), ry = 0 (y = 1) — непосредственно под верхним входом
    const startRx = 14;
    const startRy = 0;

    visited[startRy][startRx] = true;
    stack.add(const Point(startRx, startRy));
    grid[_roomYs[startRy]][_roomXs[startRx]] = 0;

    // Открытие строго 4-х входов шириной в 1 клетку:
    // Верхний: (29, 0)
    grid[MazeGrid.topEntrance.y][MazeGrid.topEntrance.x] = 0;
    // Нижний: (29, 59)
    grid[MazeGrid.bottomEntrance.y][MazeGrid.bottomEntrance.x] = 0;
    // Левый: (0, 29)
    grid[MazeGrid.leftEntrance.y][MazeGrid.leftEntrance.x] = 0;
    // Правый: (59, 29)
    grid[MazeGrid.rightEntrance.y][MazeGrid.rightEntrance.x] = 0;

    // Векторы 4-х ортогональных направлений
    final directions = [
      const Point<int>(0, -1), // Вверх
      const Point<int>(0, 1),  // Вниз
      const Point<int>(-1, 0), // Влево
      const Point<int>(1, 0),  // Вправо
    ];

    while (stack.isNotEmpty) {
      final current = stack.last;
      final availableNeighbors = <Point<int>>[];

      for (final d in directions) {
        final nrx = current.x + d.x;
        final nry = current.y + d.y;

        if (nrx >= 0 && nrx < _roomCount && nry >= 0 && nry < _roomCount) {
          if (!visited[nry][nrx]) {
            if (_canCarveEdge(grid, current, Point(nrx, nry))) {
              availableNeighbors.add(Point(nrx, nry));
            }
          }
        }
      }

      if (availableNeighbors.isEmpty) {
        stack.removeLast();
      } else {
        final next = availableNeighbors[random.nextInt(availableNeighbors.length)];
        visited[next.y][next.x] = true;
        _carveEdge(grid, current, next);
        stack.add(next);
      }
    }

    // Пост-валидация инвариантов лабиринта
    _validateMaze(grid);

    return MazeGrid.fromRawInts(grid);
  }

  /// Проверяет, не образует ли соединение между двумя комнатами блок проходов 2x2.
  bool _canCarveEdge(List<List<int>> grid, Point<int> r1, Point<int> r2) {
    final x1 = _roomXs[r1.x];
    final y1 = _roomYs[r1.y];
    final x2 = _roomXs[r2.x];
    final y2 = _roomYs[r2.y];

    final minX = min(x1, x2);
    final maxX = max(x1, x2);
    final minY = min(y1, y2);
    final maxY = max(y1, y2);

    final cellsToCarve = <Point<int>>[];
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        if (grid[y][x] == 1) {
          cellsToCarve.add(Point(x, y));
        }
      }
    }

    // Временная пробивка ячеек для проверки образования 2x2
    for (final p in cellsToCarve) {
      grid[p.y][p.x] = 0;
    }

    bool causes2x2 = false;
    for (final p in cellsToCarve) {
      for (int dy = -1; dy <= 0; dy++) {
        for (int dx = -1; dx <= 0; dx++) {
          final x0 = p.x + dx;
          final y0 = p.y + dy;
          if (x0 >= 0 && x0 + 1 < _size && y0 >= 0 && y0 + 1 < _size) {
            if (grid[y0][x0] == 0 &&
                grid[y0][x0 + 1] == 0 &&
                grid[y0 + 1][x0] == 0 &&
                grid[y0 + 1][x0 + 1] == 0) {
              causes2x2 = true;
              break;
            }
          }
        }
        if (causes2x2) break;
      }
      if (causes2x2) break;
    }

    // Откат временной пробивки
    for (final p in cellsToCarve) {
      grid[p.y][p.x] = 1;
    }

    return !causes2x2;
  }

  /// Пробивает проход между двумя соседними комнатами.
  void _carveEdge(List<List<int>> grid, Point<int> r1, Point<int> r2) {
    final x1 = _roomXs[r1.x];
    final y1 = _roomYs[r1.y];
    final x2 = _roomXs[r2.x];
    final y2 = _roomYs[r2.y];

    final minX = min(x1, x2);
    final maxX = max(x1, x2);
    final minY = min(y1, y2);
    final maxY = max(y1, y2);

    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        grid[y][x] = 0;
      }
    }
  }

  /// Проверяет топологическую корректность сгенерированного лабиринта.
  void _validateMaze(List<List<int>> grid) {
    // 1. Проверка внешнего периметра: ровно 4 входа
    int outerEntranceCount = 0;
    for (int x = 0; x < _size; x++) {
      if (grid[0][x] == 0) outerEntranceCount++;
      if (grid[_size - 1][x] == 0) outerEntranceCount++;
    }
    for (int y = 1; y < _size - 1; y++) {
      if (grid[y][0] == 0) outerEntranceCount++;
      if (grid[y][_size - 1] == 0) outerEntranceCount++;
    }
    if (outerEntranceCount != 4) {
      throw StateError(
        'Ошибка топологии: на внешнем периметре обнаружено $outerEntranceCount входов вместо 4',
      );
    }

    // 2. Проверка отсутствия блоков 2x2
    for (int y = 0; y < _size - 1; y++) {
      for (int x = 0; x < _size - 1; x++) {
        if (grid[y][x] == 0 &&
            grid[y][x + 1] == 0 &&
            grid[y + 1][x] == 0 &&
            grid[y + 1][x + 1] == 0) {
          throw StateError(
            'Ошибка топологии: обнаружен блок проходов 2x2 в ячейке ($x, $y)',
          );
        }
      }
    }

    // 3. Проверка полной связности всех проходов и доступности 4 входов (BFS)
    final visited = List.generate(_size, (_) => List.filled(_size, false));
    final queue = <Point<int>>[Point(MazeGrid.topEntrance.x, MazeGrid.topEntrance.y)];
    visited[MazeGrid.topEntrance.y][MazeGrid.topEntrance.x] = true;
    int reachablePassages = 0;

    final dirs = [
      const Point<int>(0, -1),
      const Point<int>(0, 1),
      const Point<int>(-1, 0),
      const Point<int>(1, 0),
    ];

    while (queue.isNotEmpty) {
      final p = queue.removeAt(0);
      reachablePassages++;
      for (final d in dirs) {
        final nx = p.x + d.x;
        final ny = p.y + d.y;
        if (nx >= 0 && nx < _size && ny >= 0 && ny < _size) {
          if (!visited[ny][nx] && grid[ny][nx] == 0) {
            visited[ny][nx] = true;
            queue.add(Point(nx, ny));
          }
        }
      }
    }

    if (!visited[MazeGrid.bottomEntrance.y][MazeGrid.bottomEntrance.x] ||
        !visited[MazeGrid.leftEntrance.y][MazeGrid.leftEntrance.x] ||
        !visited[MazeGrid.rightEntrance.y][MazeGrid.rightEntrance.x]) {
      throw StateError('Ошибка топологии: не все 4 входа соединены между собой');
    }

    int totalPassages = 0;
    for (int y = 0; y < _size; y++) {
      for (int x = 0; x < _size; x++) {
        if (grid[y][x] == 0) totalPassages++;
      }
    }

    if (totalPassages != reachablePassages) {
      throw StateError(
        'Ошибка топологии: в лабиринте есть изолированные проходы ($reachablePassages из $totalPassages)',
      );
    }
  }
}

