import 'package:material_ui/material_ui.dart';
import '../../domain/entities/maze_grid.dart';

/// CustomPainter для векторной отрисовки схемы лабиринта 60x60 на Canvas.
final class MazeCustomPainter extends CustomPainter {
  final MazeGrid maze;
  final double cellSize;
  final double labelMargin;

  const MazeCustomPainter({
    required this.maze,
    this.cellSize = 20.0,
    this.labelMargin = 50.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int dim = MazeGrid.dimension;
    final double gridSpan = dim * cellSize;

    // 1. Фон
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Кисти
    final wallPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final passagePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final gridBorderPaint = Paint()
      ..color = const Color(0xFFD6D6D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final entranceIndicatorPaint = Paint()
      ..color = const Color(0xFF43A047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 3. Отрисовка всех 60x60 ячеек
    for (int y = 0; y < dim; y++) {
      final double cellY = labelMargin + (y * cellSize);
      for (int x = 0; x < dim; x++) {
        final double cellX = labelMargin + (x * cellSize);
        final rect = Rect.fromLTWH(cellX, cellY, cellSize, cellSize);

        final bool isPassage = maze.isPassage(x, y);
        canvas.drawRect(rect, isPassage ? passagePaint : wallPaint);
        canvas.drawRect(rect, gridBorderPaint);

        if (maze.isEntrance(x, y)) {
          canvas.drawRect(rect.deflate(0.5), entranceIndicatorPaint);
        }
      }
    }

    // Внешняя рамка лабиринта
    final outerFramePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromLTWH(labelMargin, labelMargin, gridSpan, gridSpan),
      outerFramePaint,
    );

    // 4. Отрисовка номеров строк и столбцов (1..60) со всех 4 сторон
    final double fontSize = (cellSize * 0.45).clamp(8.0, 13.0);
    final textStyle = TextStyle(
      color: const Color(0xFF263238),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    );

    final double topLabelY = labelMargin * 0.55;
    final double bottomLabelY = labelMargin + gridSpan + (labelMargin * 0.45);
    final double leftLabelX = labelMargin * 0.55;
    final double rightLabelX = labelMargin + gridSpan + (labelMargin * 0.45);

    // Столбцы 1..60 (сверху и снизу)
    for (int x = 0; x < dim; x++) {
      final double centerX = labelMargin + (x + 0.5) * cellSize;
      final int colNum = x + 1;

      final tp = TextPainter(
        text: TextSpan(text: '$colNum', style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(centerX - (tp.width / 2), topLabelY - (tp.height / 2)),
      );

      tp.paint(
        canvas,
        Offset(centerX - (tp.width / 2), bottomLabelY - (tp.height / 2)),
      );
    }

    // Строки 1..60 (слева и справа)
    for (int y = 0; y < dim; y++) {
      final double centerY = labelMargin + (y + 0.5) * cellSize;
      final int rowNum = y + 1;

      final tp = TextPainter(
        text: TextSpan(text: '$rowNum', style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(leftLabelX - (tp.width / 2), centerY - (tp.height / 2)),
      );

      tp.paint(
        canvas,
        Offset(rightLabelX - (tp.width / 2), centerY - (tp.height / 2)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MazeCustomPainter oldDelegate) {
    return oldDelegate.maze != maze ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.labelMargin != labelMargin;
  }
}
