import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import '../../domain/entities/maze_grid.dart';
import '../../domain/interfaces/i_maze_image_exporter.dart';

/// Реализация растрового экспортера лабиринта в формате PNG с ультра-высоким разрешением.
final class MazeImageExporterImpl implements IMazeImageExporter {
  const MazeImageExporterImpl();

  @override
  Future<Uint8List> toPng(
    MazeGrid maze, {
    double cellSize = 35.0,
    double labelMargin = 80.0,
  }) async {
    const int dim = MazeGrid.dimension;
    final double gridSpan = dim * cellSize;
    final double totalSize = gridSpan + (labelMargin * 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. Очистка фона белым цветом
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, totalSize, totalSize), bgPaint);

    // 2. Кисти для стен, проходов и разделительных линий
    final wallPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final passagePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cellGridPaint = Paint()
      ..color = const Color(0xFFD6D6D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final entranceBorderPaint = Paint()
      ..color = const Color(0xFF43A047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 3. Отрисовка всех 60x60 ячеек
    for (int y = 0; y < dim; y++) {
      final double cellY = labelMargin + (y * cellSize);
      for (int x = 0; x < dim; x++) {
        final double cellX = labelMargin + (x * cellSize);
        final rect = Rect.fromLTWH(cellX, cellY, cellSize, cellSize);

        final bool isPassage = maze.isPassage(x, y);
        canvas.drawRect(rect, isPassage ? passagePaint : wallPaint);
        canvas.drawRect(rect, cellGridPaint);

        if (maze.isEntrance(x, y)) {
          canvas.drawRect(rect.deflate(1.0), entranceBorderPaint);
        }
      }
    }

    // Внешняя рамка лабиринта
    final outerFramePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(
      Rect.fromLTWH(labelMargin, labelMargin, gridSpan, gridSpan),
      outerFramePaint,
    );

    // 4. Отрисовка номеров строк и столбцов 1..60 со всех 4 сторон
    final double fontSize = (cellSize * 0.45).clamp(10.0, 16.0);
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

    // Отрисовка номеров столбцов (1..60) сверху и снизу
    for (int x = 0; x < dim; x++) {
      final double centerX = labelMargin + (x + 0.5) * cellSize;
      final int colNum = x + 1;

      final textSpan = TextSpan(text: '$colNum', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Сверху
      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2), topLabelY - (textPainter.height / 2)),
      );

      // Снизу
      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2), bottomLabelY - (textPainter.height / 2)),
      );
    }

    // Отрисовка номеров строк (1..60) слева и справа
    for (int y = 0; y < dim; y++) {
      final double centerY = labelMargin + (y + 0.5) * cellSize;
      final int rowNum = y + 1;

      final textSpan = TextSpan(text: '$rowNum', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Слева
      textPainter.paint(
        canvas,
        Offset(leftLabelX - (textPainter.width / 2), centerY - (textPainter.height / 2)),
      );

      // Справа
      textPainter.paint(
        canvas,
        Offset(rightLabelX - (textPainter.width / 2), centerY - (textPainter.height / 2)),
      );
    }

    // 5. Завершение записи и конвертация в PNG
    final picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(
      totalSize.toInt(),
      totalSize.toInt(),
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw StateError('Не удалось закодировать изображение в формат PNG');
    }

    return byteData.buffer.asUint8List();
  }
}
