import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:labirint_light/data/exporters/maze_image_exporter_impl.dart';
import 'package:labirint_light/data/generators/maze_generator_impl.dart';

void main() {
  test('Генерация образца PNG в высоком разрешении', () async {
    final generator = MazeGeneratorImpl();
    final maze = generator.generate(seed: 42);

    const exporter = MazeImageExporterImpl();
    final bytes = await exporter.toPng(maze, cellSize: 35.0, labelMargin: 80.0);

    final file = File('maze_60x60.png');
    await file.writeAsBytes(bytes);

    expect(file.existsSync(), isTrue);
    expect(bytes.length, greaterThan(10000));
  });
}

