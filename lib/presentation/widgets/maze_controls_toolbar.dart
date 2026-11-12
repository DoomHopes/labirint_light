import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import '../providers/maze_providers.dart';
import '../state/maze_state.dart';

/// Декомпозированная панель управления генерацией и скачиванием лабиринта.
final class MazeControlsToolbar extends ConsumerStatefulWidget {
  final MazeLoaded state;

  const MazeControlsToolbar({
    super.key,
    required this.state,
  });

  @override
  ConsumerState<MazeControlsToolbar> createState() => _MazeControlsToolbarState();
}

class _MazeControlsToolbarState extends ConsumerState<MazeControlsToolbar> {
  late final TextEditingController _seedController;
  double _pngResolution = 35.0; // Базовое разрешение (~2260x2260 px)

  @override
  void initState() {
    super.initState();
    _seedController = TextEditingController(text: widget.state.seed.toString());
  }

  @override
  void didUpdateWidget(covariant MazeControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.seed != widget.state.seed) {
      _seedController.text = widget.state.seed.toString();
    }
  }

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  void _onGeneratePressed() {
    final int? customSeed = int.tryParse(_seedController.text.trim());
    ref.read(mazeNotifierProvider.notifier).generateMaze(customSeed);
  }

  void _onRandomSeedPressed() {
    final int newSeed = Random().nextInt(1000000);
    _seedController.text = newSeed.toString();
    ref.read(mazeNotifierProvider.notifier).generateMaze(newSeed);
  }

  @override
  Widget build(BuildContext context) {
    final isExporting = widget.state.isExporting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Поле ввода сида
            SizedBox(
              width: 130.0,
              child: TextField(
                controller: _seedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Seed',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Кнопка случайного сида
            IconButton.outlined(
              onPressed: isExporting ? null : _onRandomSeedPressed,
              tooltip: 'Случайный Seed',
              icon: const Icon(Icons.shuffle, size: 20),
            ),
            const SizedBox(width: 8.0),

            // Кнопка генерации
            FilledButton.icon(
              onPressed: isExporting ? null : _onGeneratePressed,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Сгенерировать'),
            ),
            const SizedBox(width: 16.0),

            const VerticalDivider(width: 1, thickness: 1, indent: 6, endIndent: 6),
            const SizedBox(width: 16.0),

            // Выбор разрешения PNG
            DropdownButton<double>(
              value: _pngResolution,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: 25.0,
                  child: Text('PNG 1660x1660 px'),
                ),
                DropdownMenuItem(
                  value: 35.0,
                  child: Text('PNG 2260x2260 px (High-Res)'),
                ),
                DropdownMenuItem(
                  value: 50.0,
                  child: Text('PNG 3160x3160 px (Ultra-HD)'),
                ),
              ],
              onChanged: isExporting
                  ? null
                  : (val) {
                      if (val != null) {
                        setState(() => _pngResolution = val);
                      }
                    },
            ),
            const SizedBox(width: 12.0),

            // Кнопка сохранения PNG
            FilledButton.tonalIcon(
              onPressed: isExporting
                  ? null
                  : () {
                      ref
                          .read(mazeNotifierProvider.notifier)
                          .exportPng(cellSize: _pngResolution);
                    },
              icon: isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.image, size: 18),
              label: const Text('Скачать PNG'),
            ),
            const SizedBox(width: 8.0),

            // Кнопка сохранения SVG
            FilledButton.tonalIcon(
              onPressed: isExporting
                  ? null
                  : () {
                      ref.read(mazeNotifierProvider.notifier).exportSvg();
                    },
              icon: isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.code, size: 18),
              label: const Text('Скачать SVG'),
            ),
            const SizedBox(width: 8.0),

            // Кнопка сохранения .litematic (Litematica)
            FilledButton.tonalIcon(
              onPressed: isExporting
                  ? null
                  : () {
                      ref.read(mazeNotifierProvider.notifier).exportLitematic();
                    },
              icon: isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.layers, size: 18),
              label: const Text('Скачать .litematic'),
            ),
            const SizedBox(width: 8.0),

            // Кнопка сохранения .schem (WorldEdit)
            FilledButton.tonalIcon(
              onPressed: isExporting
                  ? null
                  : () {
                      ref.read(mazeNotifierProvider.notifier).exportSchematic();
                    },
              icon: isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.grid_view, size: 18),
              label: const Text('Скачать .schem'),
            ),
          ],
        ),
      ),
    );
  }
}
