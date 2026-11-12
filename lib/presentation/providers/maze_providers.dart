import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/exporters/maze_image_exporter_impl.dart';
import '../../data/exporters/maze_litematic_exporter_impl.dart';
import '../../data/exporters/maze_schematic_exporter_impl.dart';
import '../../data/exporters/maze_svg_exporter_impl.dart';
import '../../data/generators/maze_generator_impl.dart';
import '../../data/services/file_saver_service_impl.dart';
import '../../domain/interfaces/i_file_saver_service.dart';
import '../../domain/interfaces/i_maze_generator.dart';
import '../../domain/interfaces/i_maze_image_exporter.dart';
import '../../domain/interfaces/i_maze_litematic_exporter.dart';
import '../../domain/interfaces/i_maze_schematic_exporter.dart';
import '../../domain/interfaces/i_maze_svg_exporter.dart';
import '../state/maze_notifier.dart';
import '../state/maze_state.dart';

/// Провайдер генератора лабиринтов.
final mazeGeneratorProvider = Provider<IMazeGenerator>((ref) {
  return MazeGeneratorImpl();
});

/// Провайдер SVG экспортера.
final mazeSvgExporterProvider = Provider<IMazeSvgExporter>((ref) {
  return const MazeSvgExporterImpl();
});

/// Провайдер растрового PNG экспортера высокого разрешения.
final mazeImageExporterProvider = Provider<IMazeImageExporter>((ref) {
  return const MazeImageExporterImpl();
});

/// Провайдер экспортера схематик WorldEdit (.schem).
final mazeSchematicExporterProvider = Provider<IMazeSchematicExporter>((ref) {
  return const MazeSchematicExporterImpl();
});

/// Провайдер экспортера схематик Litematica (.litematic).
final mazeLitematicExporterProvider = Provider<IMazeLitematicExporter>((ref) {
  return const MazeLitematicExporterImpl();
});

/// Провайдер сервиса сохранения файлов на диск.
final fileSaverServiceProvider = Provider<IFileSaverService>((ref) {
  return const FileSaverServiceImpl();
});

/// Главный NotifierProvider управления состоянием лабиринта.
final mazeNotifierProvider = NotifierProvider<MazeNotifier, MazeState>(() {
  return MazeNotifier(
    generator: MazeGeneratorImpl(),
    svgExporter: const MazeSvgExporterImpl(),
    imageExporter: const MazeImageExporterImpl(),
    schematicExporter: const MazeSchematicExporterImpl(),
    litematicExporter: const MazeLitematicExporterImpl(),
    fileSaverService: const FileSaverServiceImpl(),
  );
});
