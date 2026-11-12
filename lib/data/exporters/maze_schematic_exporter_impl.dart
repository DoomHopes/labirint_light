import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../domain/entities/maze_grid.dart';
import '../../domain/interfaces/i_maze_schematic_exporter.dart';

/// Вспомогательный класс для двоичной записи тегов спецификации NBT (Named Binary Tag).
final class _NbtWriter {
  final BytesBuilder _builder = BytesBuilder();

  void _writeByte(int value) => _builder.addByte(value);

  void _writeShort(int value) {
    _builder.add([
      (value >> 8) & 0xFF,
      value & 0xFF,
    ]);
  }

  void _writeInt(int value) {
    _builder.add([
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ]);
  }

  void _writeString(String str) {
    final bytes = utf8.encode(str);
    _writeShort(bytes.length);
    _builder.add(bytes);
  }

  void _writeNamedTagHeader(int tagType, String name) {
    _writeByte(tagType);
    _writeString(name);
  }

  void writeIntTag(String name, int value) {
    _writeNamedTagHeader(3, name); // TAG_Int = 3
    _writeInt(value);
  }

  void writeShortTag(String name, int value) {
    _writeNamedTagHeader(2, name); // TAG_Short = 2
    _writeShort(value);
  }

  void writeByteArrayTag(String name, Uint8List data) {
    _writeNamedTagHeader(7, name); // TAG_Byte_Array = 7
    _writeInt(data.length);
    _builder.add(data);
  }

  void writeIntArrayTag(String name, List<int> values) {
    _writeNamedTagHeader(11, name); // TAG_Int_Array = 11
    _writeInt(values.length);
    for (final v in values) {
      _writeInt(v);
    }
  }

  void startCompound(String name) {
    _writeNamedTagHeader(10, name); // TAG_Compound = 10
  }

  void endCompound() {
    _writeByte(0); // TAG_End = 0
  }

  Uint8List toBytes() => _builder.toBytes();
}

/// Реализация экспортера лабиринта в схематику WorldEdit (Sponge Schematic v2).
final class MazeSchematicExporterImpl implements IMazeSchematicExporter {
  const MazeSchematicExporterImpl();

  @override
  Uint8List toSchematic(
    MazeGrid maze, {
    String wallBlock = 'minecraft:deepslate_bricks',
  }) {
    const int dim = MazeGrid.dimension; // 60
    const int height = 1;               // Ровно 1 слой

    final nbt = _NbtWriter();

    // Корневой тег Compound
    nbt.startCompound('Schematic');

    // Метаданные спецификации Sponge Schematic v2
    nbt.writeIntTag('Version', 2);
    nbt.writeIntTag('DataVersion', 3465); // Minecraft 1.20+
    nbt.writeShortTag('Width', dim);       // X = 60
    nbt.writeShortTag('Height', height);   // Y = 1
    nbt.writeShortTag('Length', dim);      // Z = 60
    nbt.writeIntArrayTag('Offset', const [0, 0, 0]);
    nbt.writeIntTag('PaletteMax', 2);

    // Палитра блоков
    // 0 = воздух (белые клетки / проходы)
    // 1 = глубинносланцевые кирпичи (черные клетки / стены)
    nbt.startCompound('Palette');
    nbt.writeIntTag('minecraft:air', 0);
    nbt.writeIntTag(wallBlock, 1);
    nbt.endCompound();

    // Массив блоков: порядок обхода (y * Length + z) * Width + x
    // При Height = 1 и y = 0: индекс = z * 60 + x
    final blockData = Uint8List(dim * dim * height);
    for (int z = 0; z < dim; z++) {
      for (int x = 0; x < dim; x++) {
        final int index = z * dim + x;
        // Белый = проход (0: воздух), Черный = стена (1: блок)
        blockData[index] = maze.isPassage(x, z) ? 0 : 1;
      }
    }

    nbt.writeByteArrayTag('BlockData', blockData);
    nbt.endCompound(); // Завершение корневого Compound

    // Сжатие NBT-потока в GZip
    final rawNbtBytes = nbt.toBytes();
    final gzippedBytes = gzip.encode(rawNbtBytes);

    return Uint8List.fromList(gzippedBytes);
  }
}

