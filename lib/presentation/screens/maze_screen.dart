import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import '../providers/maze_providers.dart';
import '../state/maze_state.dart';
import '../widgets/maze_controls_toolbar.dart';
import '../widgets/maze_interactive_viewer.dart';

/// Главный экран генератора и визуализатора лабиринта 60x60.
final class MazeScreen extends ConsumerWidget {
  const MazeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Подписка на уведомления
    ref.listen<MazeState>(mazeNotifierProvider, (previous, next) {
      if (next is MazeLoaded && next.notificationMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.notificationMessage!),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        ref.read(mazeNotifierProvider.notifier).clearNotification();
      }
    });

    final mazeState = ref.watch(mazeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабиринт 60x60 (Recursive Backtracker)'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SafeArea(
        child: switch (mazeState) {
          MazeInitial() || MazeLoading() => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Генерация лабиринта 60x60...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          MazeError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        ref.read(mazeNotifierProvider.notifier).generateMaze();
                      },
                      child: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              ),
            ),
          MazeLoaded() => Column(
              children: [
                MazeControlsToolbar(state: mazeState),
                Expanded(
                  child: MazeInteractiveViewer(maze: mazeState.maze),
                ),
              ],
            ),
        },
      ),
    );
  }
}
