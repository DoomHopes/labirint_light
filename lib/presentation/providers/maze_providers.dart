import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/exporters/maze_image_exporter_impl.dart';
import '../../data/exporters/maze_svg_exporter_impl.dart';
import '../../data/generators/maze_generator_impl.dart';
import '../../data/services/file_saver_service_impl.dart';
import '../../domain/interfaces/i_file_saver_service.dart';
import '../../domain/interfaces/i_maze_generator.dart';
import '../../domain/interfaces/i_maze_image_exporter.dart';
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

/// Провайдер сервиса сохранения файлов на диск.
final fileSaverServiceProvider = Provider<IFileSaverService>((ref) {
  return const FileSaverServiceImpl();
});

/// Главный NotifierProvider управления состоянием лабиринта.
final mazeNotifierProvider = NotifierProvider<MazeNotifier, MazeState>(() {
  // Поскольку NotifierProvider конструирует MazeNotifier без прямого ref в конструкторе,
  // создаем фабрику с инъекцией синглтон-зависимостей:
  return MazeNotifier(
    generator: MazeGeneratorImpl(),
    svgExporter: const MazeSvgExporterImpl(),
    imageExporter: const MazeImageExporterImpl(),
    fileSaverService: const FileSaverServiceImpl(),
  );
});

