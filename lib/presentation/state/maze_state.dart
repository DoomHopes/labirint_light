import 'package:meta/meta.dart';
import '../../domain/entities/maze_grid.dart';

/// Состояние экрана генерации и экспорта лабиринта.
@immutable
sealed class MazeState {
  const MazeState();
}

/// Начальное состояние до первой генерации.
final class MazeInitial extends MazeState {
  const MazeInitial();
}

/// Состояние генерации нового лабиринта.
final class MazeLoading extends MazeState {
  const MazeLoading();
}

/// Лабиринт успешно сгенерирован и готов к просмотру / экспорту.
final class MazeLoaded extends MazeState {
  /// Текущий экземпляр сетки лабиринта.
  final MazeGrid maze;

  /// Числовой сид генерации.
  final int seed;

  /// Флаг выполнения процесса экспорта в файл.
  final bool isExporting;

  /// Информационное сообщение (например, об успешном сохранении).
  final String? notificationMessage;

  const MazeLoaded({
    required this.maze,
    required this.seed,
    this.isExporting = false,
    this.notificationMessage,
  });

  /// Создает копию состояния с обновленными полями.
  MazeLoaded copyWith({
    MazeGrid? maze,
    int? seed,
    bool? isExporting,
    String? notificationMessage,
  }) {
    return MazeLoaded(
      maze: maze ?? this.maze,
      seed: seed ?? this.seed,
      isExporting: isExporting ?? this.isExporting,
      notificationMessage: notificationMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MazeLoaded &&
          runtimeType == other.runtimeType &&
          maze == other.maze &&
          seed == other.seed &&
          isExporting == other.isExporting &&
          notificationMessage == other.notificationMessage;

  @override
  int get hashCode => Object.hash(maze, seed, isExporting, notificationMessage);
}

/// Состояние ошибки.
final class MazeError extends MazeState {
  /// Описание ошибки.
  final String message;

  const MazeError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MazeError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

