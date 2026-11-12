// ignore_for_file: prefer_initializing_formals
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/interfaces/i_file_saver_service.dart';
import '../../domain/interfaces/i_maze_generator.dart';
import '../../domain/interfaces/i_maze_image_exporter.dart';
import '../../domain/interfaces/i_maze_litematic_exporter.dart';
import '../../domain/interfaces/i_maze_schematic_exporter.dart';
import '../../domain/interfaces/i_maze_svg_exporter.dart';
import 'maze_state.dart';

/// Бизнес-логика управления состоянием генерации и экспорта лабиринта.
final class MazeNotifier extends Notifier<MazeState> {
  final IMazeGenerator _generator;
  final IMazeSvgExporter _svgExporter;
  final IMazeImageExporter _imageExporter;
  final IMazeSchematicExporter _schematicExporter;
  final IMazeLitematicExporter _litematicExporter;
  final IFileSaverService _fileSaverService;

  MazeNotifier({
    required IMazeGenerator generator,
    required IMazeSvgExporter svgExporter,
    required IMazeImageExporter imageExporter,
    required IMazeSchematicExporter schematicExporter,
    required IMazeLitematicExporter litematicExporter,
    required IFileSaverService fileSaverService,
  })  : _generator = generator,
        _svgExporter = svgExporter,
        _imageExporter = imageExporter,
        _schematicExporter = schematicExporter,
        _litematicExporter = litematicExporter,
        _fileSaverService = fileSaverService;

  @override
  MazeState build() {
    final int initialSeed = Random().nextInt(1000000);
    try {
      final maze = _generator.generate(seed: initialSeed);
      return MazeLoaded(maze: maze, seed: initialSeed);
    } catch (e) {
      return MazeError('Ошибка инициализации лабиринта: $e');
    }
  }

  /// Генерирует новый лабиринт со случайным или заданным [customSeed].
  void generateMaze([int? customSeed]) {
    state = const MazeLoading();
    final int seed = customSeed ?? Random().nextInt(1000000);
    try {
      final maze = _generator.generate(seed: seed);
      state = MazeLoaded(maze: maze, seed: seed);
    } catch (e) {
      state = MazeError('Не удалось сгенерировать лабиринт: $e');
    }
  }

  /// Экспортирует и сохраняет текущий лабиринт в формате PNG в высоком разрешении.
  Future<void> exportPng({double cellSize = 35.0}) async {
    final currentState = state;
    if (currentState is! MazeLoaded || currentState.isExporting) return;

    state = currentState.copyWith(isExporting: true, notificationMessage: null);

    try {
      final pngBytes = await _imageExporter.toPng(
        currentState.maze,
        cellSize: cellSize,
      );

      final result = await _fileSaverService.saveFile(
        bytes: pngBytes,
        suggestedFileName: 'maze_60x60_seed_${currentState.seed}',
        extension: 'png',
        mimeType: 'image/png',
      );

      switch (result) {
        case FileSaveSuccess(:final path):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'PNG успешно сохранен: $path',
          );
        case FileSaveCancelled():
          state = currentState.copyWith(isExporting: false);
        case FileSaveFailure(:final message):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'Ошибка сохранения PNG: $message',
          );
      }
    } catch (e) {
      state = currentState.copyWith(
        isExporting: false,
        notificationMessage: 'Ошибка экспорта в PNG: $e',
      );
    }
  }

  /// Экспортирует и сохраняет текущий лабиринт в векторном формате SVG.
  Future<void> exportSvg({double cellSize = 24.0}) async {
    final currentState = state;
    if (currentState is! MazeLoaded || currentState.isExporting) return;

    state = currentState.copyWith(isExporting: true, notificationMessage: null);

    try {
      final svgString = _svgExporter.toSvg(
        currentState.maze,
        cellSize: cellSize,
      );
      final svgBytes = utf8.encode(svgString);

      final result = await _fileSaverService.saveFile(
        bytes: svgBytes,
        suggestedFileName: 'maze_60x60_seed_${currentState.seed}',
        extension: 'svg',
        mimeType: 'image/svg+xml',
      );

      switch (result) {
        case FileSaveSuccess(:final path):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'SVG успешно сохранен: $path',
          );
        case FileSaveCancelled():
          state = currentState.copyWith(isExporting: false);
        case FileSaveFailure(:final message):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'Ошибка сохранения SVG: $message',
          );
      }
    } catch (e) {
      state = currentState.copyWith(
        isExporting: false,
        notificationMessage: 'Ошибка экспорта в SVG: $e',
      );
    }
  }

  /// Экспортирует лабиринт в схематику WorldEdit (.schem) строго в 1 слой.
  Future<void> exportSchematic({
    String wallBlock = 'minecraft:deepslate_bricks',
  }) async {
    final currentState = state;
    if (currentState is! MazeLoaded || currentState.isExporting) return;

    state = currentState.copyWith(isExporting: true, notificationMessage: null);

    try {
      final schematicBytes = _schematicExporter.toSchematic(
        currentState.maze,
        wallBlock: wallBlock,
      );

      final result = await _fileSaverService.saveFile(
        bytes: schematicBytes,
        suggestedFileName: 'maze_60x60_seed_${currentState.seed}',
        extension: 'schem',
        mimeType: 'application/gzip',
      );

      switch (result) {
        case FileSaveSuccess(:final path):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'Схематика WorldEdit (.schem) сохранена: $path',
          );
        case FileSaveCancelled():
          state = currentState.copyWith(isExporting: false);
        case FileSaveFailure(:final message):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'Ошибка сохранения .schem: $message',
          );
      }
    } catch (e) {
      state = currentState.copyWith(
        isExporting: false,
        notificationMessage: 'Ошибка экспорта схематики: $e',
      );
    }
  }

  /// Экспортирует лабиринт в нативный формат Litematica (.litematic) строго в 1 слой.
  Future<void> exportLitematic({
    String wallBlock = 'minecraft:deepslate_bricks',
  }) async {
    final currentState = state;
    if (currentState is! MazeLoaded || currentState.isExporting) return;

    state = currentState.copyWith(isExporting: true, notificationMessage: null);

    try {
      final litematicBytes = _litematicExporter.toLitematic(
        currentState.maze,
        wallBlock: wallBlock,
      );

      final result = await _fileSaverService.saveFile(
        bytes: litematicBytes,
        suggestedFileName: 'maze_60x60_seed_${currentState.seed}',
        extension: 'litematic',
        mimeType: 'application/gzip',
      );

      switch (result) {
        case FileSaveSuccess(:final path):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'Схематика Litematica (.litematic) сохранена: $path',
          );
        case FileSaveCancelled():
          state = currentState.copyWith(isExporting: false);
        case FileSaveFailure(:final message):
          state = currentState.copyWith(
            isExporting: false,
            notificationMessage: 'Ошибка сохранения .litematic: $message',
          );
      }
    } catch (e) {
      state = currentState.copyWith(
        isExporting: false,
        notificationMessage: 'Ошибка экспорта .litematic: $e',
      );
    }
  }

  /// Сбрасывает текущее всплывающее уведомление.
  void clearNotification() {
    final currentState = state;
    if (currentState is MazeLoaded && currentState.notificationMessage != null) {
      state = currentState.copyWith(notificationMessage: null);
    }
  }
}
