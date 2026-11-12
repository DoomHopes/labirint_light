import '../../domain/entities/maze_grid.dart';
import '../../domain/interfaces/i_maze_svg_exporter.dart';

/// Реализация векторного экспортера лабиринта в формате SVG.
final class MazeSvgExporterImpl implements IMazeSvgExporter {
  const MazeSvgExporterImpl();

  @override
  String toSvg(
    MazeGrid maze, {
    double cellSize = 24.0,
    double labelMargin = 60.0,
  }) {
    final int dim = MazeGrid.dimension;
    final double gridSpan = dim * cellSize;
    final double totalSize = gridSpan + (labelMargin * 2);

    final sb = StringBuffer();

    // Заголовок SVG
    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="${totalSize.toStringAsFixed(1)}" '
      'height="${totalSize.toStringAsFixed(1)}" '
      'viewBox="0 0 ${totalSize.toStringAsFixed(1)} ${totalSize.toStringAsFixed(1)}">',
    );

    // Стили шрифта и отрисовки
    final double fontSize = (cellSize * 0.45).clamp(8.0, 14.0);
    sb.writeln('  <style>');
    sb.writeln('    .bg { fill: #FFFFFF; }');
    sb.writeln('    .wall { fill: #000000; stroke: #888888; stroke-width: 0.5px; }');
    sb.writeln('    .passage { fill: #FFFFFF; stroke: #CCCCCC; stroke-width: 0.5px; }');
    sb.writeln('    .entrance { fill: #E8F5E9; stroke: #4CAF50; stroke-width: 1px; }');
    sb.writeln(
      '    .label { font-family: "Segoe UI", Roboto, Arial, sans-serif; '
      'font-size: ${fontSize.toStringAsFixed(1)}px; font-weight: 600; fill: #263238; '
      'text-anchor: middle; dominant-baseline: central; }',
    );
    sb.writeln('  </style>');

    // Общий белый фон
    sb.writeln(
      '  <rect width="100%" height="100%" class="bg" />',
    );

    // Отрисовка 60x60 ячеек
    sb.writeln('  <!-- Сетка лабиринта 60x60 -->');
    sb.writeln('  <g id="cells">');
    for (int y = 0; y < dim; y++) {
      final double cellY = labelMargin + (y * cellSize);
      for (int x = 0; x < dim; x++) {
        final double cellX = labelMargin + (x * cellSize);
        final bool isPassage = maze.isPassage(x, y);
        final String cssClass = isPassage ? 'passage' : 'wall';

        sb.writeln(
          '    <rect x="${cellX.toStringAsFixed(1)}" y="${cellY.toStringAsFixed(1)}" '
          'width="${cellSize.toStringAsFixed(1)}" height="${cellSize.toStringAsFixed(1)}" '
          'class="$cssClass" />',
        );
      }
    }
    sb.writeln('  </g>');

    // Отрисовка нумерации со всех четырех сторон (1..60)
    sb.writeln('  <!-- Нумерация столбцов и строк 1..60 -->');
    sb.writeln('  <g id="labels">');

    // 1. Верхние и нижние номера столбцов (1..60)
    final double topLabelY = labelMargin * 0.55;
    final double bottomLabelY = labelMargin + gridSpan + (labelMargin * 0.45);

    for (int x = 0; x < dim; x++) {
      final double centerX = labelMargin + (x + 0.5) * cellSize;
      final int colNum = x + 1;

      // Сверху
      sb.writeln(
        '    <text x="${centerX.toStringAsFixed(1)}" y="${topLabelY.toStringAsFixed(1)}" '
        'class="label">$colNum</text>',
      );

      // Снизу
      sb.writeln(
        '    <text x="${centerX.toStringAsFixed(1)}" y="${bottomLabelY.toStringAsFixed(1)}" '
        'class="label">$colNum</text>',
      );
    }

    // 2. Левые и правые номера строк (1..60)
    final double leftLabelX = labelMargin * 0.55;
    final double rightLabelX = labelMargin + gridSpan + (labelMargin * 0.45);

    for (int y = 0; y < dim; y++) {
      final double centerY = labelMargin + (y + 0.5) * cellSize;
      final int rowNum = y + 1;

      // Слева
      sb.writeln(
        '    <text x="${leftLabelX.toStringAsFixed(1)}" y="${centerY.toStringAsFixed(1)}" '
        'class="label">$rowNum</text>',
      );

      // Справа
      sb.writeln(
        '    <text x="${rightLabelX.toStringAsFixed(1)}" y="${centerY.toStringAsFixed(1)}" '
        'class="label">$rowNum</text>',
      );
    }
    sb.writeln('  </g>');

    sb.writeln('</svg>');
    return sb.toString();
  }
}

