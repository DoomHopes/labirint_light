import 'package:material_ui/material_ui.dart';
import '../../domain/entities/maze_grid.dart';
import '../painters/maze_custom_painter.dart';

/// Виджет интерактивного просмотра схемы лабиринта с поддержкой зума и панорамирования.
final class MazeInteractiveViewer extends StatelessWidget {
  final MazeGrid maze;
  final double cellSize;
  final double labelMargin;

  const MazeInteractiveViewer({
    super.key,
    required this.maze,
    this.cellSize = 20.0,
    this.labelMargin = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    const int dim = MazeGrid.dimension;
    final double totalDimension = (dim * cellSize) + (labelMargin * 2);

    return Container(
      color: const Color(0xFFF0F2F5),
      child: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(100.0),
          minScale: 0.3,
          maxScale: 6.0,
          clipBehavior: Clip.none,
          child: Container(
            width: totalDimension,
            height: totalDimension,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 16.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CustomPaint(
              size: Size(totalDimension, totalDimension),
              painter: MazeCustomPainter(
                maze: maze,
                cellSize: cellSize,
                labelMargin: labelMargin,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
