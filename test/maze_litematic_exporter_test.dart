import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:labirint_light/data/exporters/maze_litematic_exporter_impl.dart';
import 'package:labirint_light/data/generators/maze_generator_impl.dart';
import 'package:labirint_light/domain/entities/maze_grid.dart';

void main() {
  group('MazeLitematicExporterImpl', () {
    late MazeGeneratorImpl generator;
    late MazeLitematicExporterImpl exporter;

    setUp(() {
      generator = MazeGeneratorImpl();
      exporter = const MazeLitematicExporterImpl();
    });

    test('Формирует валидный GZip архив со схематикой Litematica (.litematic)', () {
      final maze = generator.generate(seed: 42);
      final bytes = exporter.toLitematic(maze);

      expect(bytes.length, greaterThan(0));
      // Сигнатура GZip
      expect(bytes[0], equals(0x1F));
      expect(bytes[1], equals(0x8B));

      // Проверка успешной распаковки
      final decompressed = gzip.decode(bytes);
      expect(decompressed.length, greaterThan(1000));
      expect(decompressed[0], equals(10), reason: 'Корень должен быть Compound (10)');
    });

    test('Битовая упаковка BlockStates корректно хранит ячейки 60x1x60', () {
      final maze = generator.generate(seed: 42);
      final bytes = exporter.toLitematic(maze);
      final decompressed = Uint8List.fromList(gzip.decode(bytes));

      // Поиск тега BlockStates (тип 12, имя BlockStates)
      final namePattern = 'BlockStates'.codeUnits;
      int offset = -1;

      for (int i = 0; i < decompressed.length - namePattern.length - 4; i++) {
        bool match = true;
        for (int j = 0; j < namePattern.length; j++) {
          if (decompressed[i + j] != namePattern[j]) {
            match = false;
            break;
          }
        }
        if (match) {
          offset = i + namePattern.length;
          break;
        }
      }

      expect(offset, isNot(equals(-1)), reason: 'Тег BlockStates должен присутствовать');

      final reader = ByteData.sublistView(decompressed);
      final longCount = reader.getInt32(offset);
      // 3600 ячеек * 2 бита = 7200 бит -> 113 Longs
      expect(longCount, equals(113));

      final longs = List<int>.generate(longCount, (i) {
        return reader.getInt64(offset + 4 + (i * 8));
      });

      // Проверяем 4 входа: должны иметь значение 0 (воздух)
      int getPaletteVal(int x, int z) {
        final int blockIndex = z * 60 + x;
        final int longIndex = blockIndex ~/ 32;
        final int bitOffset = (blockIndex % 32) * 2;
        return (longs[longIndex] >> bitOffset) & 0x03;
      }

      expect(getPaletteVal(MazeGrid.topEntrance.x, MazeGrid.topEntrance.y), equals(0));
      expect(getPaletteVal(MazeGrid.bottomEntrance.x, MazeGrid.bottomEntrance.y), equals(0));
      expect(getPaletteVal(MazeGrid.leftEntrance.x, MazeGrid.leftEntrance.y), equals(0));
      expect(getPaletteVal(MazeGrid.rightEntrance.x, MazeGrid.rightEntrance.y), equals(0));

      // Проверяем все 3600 ячеек на строгое соответствие лабиринту
      for (int z = 0; z < 60; z++) {
        for (int x = 0; x < 60; x++) {
          final int expected = maze.isPassage(x, z) ? 0 : 1;
          final int actual = getPaletteVal(x, z);
          expect(actual, equals(expected), reason: 'Несовпадение ячейки в ($x, $z)');
        }
      }
    });
  });
}

