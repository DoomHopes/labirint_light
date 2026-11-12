import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:labirint_light/data/exporters/maze_schematic_exporter_impl.dart';
import 'package:labirint_light/data/generators/maze_generator_impl.dart';
import 'package:labirint_light/domain/entities/maze_grid.dart';

void main() {
  group('MazeSchematicExporterImpl', () {
    late MazeGeneratorImpl generator;
    late MazeSchematicExporterImpl exporter;

    setUp(() {
      generator = MazeGeneratorImpl();
      exporter = const MazeSchematicExporterImpl();
    });

    test('Формирует валидный GZip архив со схематикой WorldEdit', () {
      final maze = generator.generate(seed: 42);
      final bytes = exporter.toSchematic(maze);

      expect(bytes.length, greaterThan(0));
      // Проверка сигнатуры GZip (1F 8B)
      expect(bytes[0], equals(0x1F));
      expect(bytes[1], equals(0x8B));

      // Проверка успешной распаковки
      final decompressed = gzip.decode(bytes);
      expect(decompressed.length, greaterThan(3600));
    });

    test('BlockData содержит ровно 3600 ячеек (60x1x60)', () {
      final maze = generator.generate(seed: 42);
      final bytes = exporter.toSchematic(maze);
      final decompressed = Uint8List.fromList(gzip.decode(bytes));

      // Находим тег BlockData (тип 7, имя BlockData)
      // В NBT: 7 (byte), length (2 bytes), "BlockData" (9 bytes), data_length (4 bytes: 3600)
      final namePattern = 'BlockData'.codeUnits;
      int blockDataOffset = -1;

      for (int i = 0; i < decompressed.length - namePattern.length - 4; i++) {
        bool match = true;
        for (int j = 0; j < namePattern.length; j++) {
          if (decompressed[i + j] != namePattern[j]) {
            match = false;
            break;
          }
        }
        if (match) {
          blockDataOffset = i + namePattern.length;
          break;
        }
      }

      expect(blockDataOffset, isNot(equals(-1)), reason: 'Тег BlockData должен присутствовать');

      final reader = ByteData.sublistView(decompressed);
      final dataLength = reader.getInt32(blockDataOffset);
      expect(dataLength, equals(3600), reason: 'Размер BlockData для 60x1x60 должен быть ровно 3600');

      final blockBytes = decompressed.sublist(
        blockDataOffset + 4,
        blockDataOffset + 4 + dataLength,
      );

      // Проверяем 4 входа: должны иметь значение 0 (воздух)
      // Top entrance: x = 29, z = 0 -> index = 0 * 60 + 29 = 29
      expect(blockBytes[MazeGrid.topEntrance.y * 60 + MazeGrid.topEntrance.x], equals(0));
      // Bottom entrance: x = 29, z = 59 -> index = 59 * 60 + 29 = 3569
      expect(blockBytes[MazeGrid.bottomEntrance.y * 60 + MazeGrid.bottomEntrance.x], equals(0));
      // Left entrance: x = 0, z = 29 -> index = 29 * 60 + 0 = 1740
      expect(blockBytes[MazeGrid.leftEntrance.y * 60 + MazeGrid.leftEntrance.x], equals(0));
      // Right entrance: x = 59, z = 29 -> index = 29 * 60 + 59 = 1799
      expect(blockBytes[MazeGrid.rightEntrance.y * 60 + MazeGrid.rightEntrance.x], equals(0));

      // Проверяем соответствие ячеек лабиринта
      for (int z = 0; z < 60; z++) {
        for (int x = 0; x < 60; x++) {
          final int expected = maze.isPassage(x, z) ? 0 : 1;
          final int actual = blockBytes[z * 60 + x];
          expect(actual, equals(expected), reason: 'Несовпадение ячейки в ($x, $z)');
        }
      }
    });
  });
}

