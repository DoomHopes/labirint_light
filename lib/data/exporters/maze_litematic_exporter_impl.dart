import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../domain/entities/maze_grid.dart';
import '../../domain/interfaces/i_maze_litematic_exporter.dart';

/// Вспомогательный класс для двоичной записи тегов спецификации NBT.
final class _LitematicNbtWriter {
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

  void _writeLong(int value) {
    final bd = ByteData(8);
    bd.setInt64(0, value, Endian.big);
    _builder.add(bd.buffer.asUint8List());
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

  void writeLongTag(String name, int value) {
    _writeNamedTagHeader(4, name); // TAG_Long = 4
    _writeLong(value);
  }

  void writeStringTag(String name, String value) {
    _writeNamedTagHeader(8, name); // TAG_String = 8
    _writeString(value);
  }

  void writeLongArrayTag(String name, List<int> values) {
    _writeNamedTagHeader(12, name); // TAG_Long_Array = 12
    _writeInt(values.length);
    for (final v in values) {
      _writeLong(v);
    }
  }

  void startCompound(String name) {
    _writeNamedTagHeader(10, name); // TAG_Compound = 10
  }

  void endCompound() {
    _writeByte(0); // TAG_End = 0
  }

  void startList(String name, int elemTagType, int count) {
    _writeNamedTagHeader(9, name); // TAG_List = 9
    _writeByte(elemTagType);
    _writeInt(count);
  }

  Uint8List toBytes() => _builder.toBytes();
}

/// Реализация экспортера лабиринта в нативный формат Litematica (.litematic).
final class MazeLitematicExporterImpl implements IMazeLitematicExporter {
  const MazeLitematicExporterImpl();

  @override
  Uint8List toLitematic(
    MazeGrid maze, {
    String wallBlock = 'minecraft:deepslate_bricks',
    String author = 'Antigravity',
  }) {
    const int dim = MazeGrid.dimension; // 60
    const int height = 1;               // 1 слой
    const int totalVolume = dim * height * dim; // 3600

    // Подсчет количества блоков стен
    int totalWallBlocks = 0;
    for (int y = 0; y < dim; y++) {
      for (int x = 0; x < dim; x++) {
        if (maze.isWall(x, y)) totalWallBlocks++;
      }
    }

    final nbt = _LitematicNbtWriter();

    // 1. Корневой Compound
    nbt.startCompound('');
    nbt.writeIntTag('MinecraftDataVersion', 3465); // Minecraft 1.20+
    nbt.writeIntTag('Version', 6);                 // Спецификация Litematica v6

    // 2. Метаданные (Metadata)
    nbt.startCompound('Metadata');
    nbt.writeStringTag('Author', author);
    nbt.writeStringTag('Description', 'Лабиринт 60x60 в 1 слой (глубинносланцевые кирпичи)');
    nbt.writeStringTag('Name', 'maze_60x60');

    nbt.startCompound('EnclosingSize');
    nbt.writeIntTag('x', dim);
    nbt.writeIntTag('y', height);
    nbt.writeIntTag('z', dim);
    nbt.endCompound();

    nbt.writeIntTag('RegionCount', 1);
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    nbt.writeLongTag('TimeCreated', nowMs);
    nbt.writeLongTag('TimeModified', nowMs);
    nbt.writeIntTag('TotalBlocks', totalWallBlocks);
    nbt.writeIntTag('TotalVolume', totalVolume);
    nbt.endCompound(); // End Metadata

    // 3. Регионы (Regions)
    nbt.startCompound('Regions');
    nbt.startCompound('maze_60x60');

    // Локальная позиция и размер региона
    nbt.startCompound('Position');
    nbt.writeIntTag('x', 0);
    nbt.writeIntTag('y', 0);
    nbt.writeIntTag('z', 0);
    nbt.endCompound();

    nbt.startCompound('Size');
    nbt.writeIntTag('x', dim);
    nbt.writeIntTag('y', height);
    nbt.writeIntTag('z', dim);
    nbt.endCompound();

    // Палитра блоков (BlockStatePalette)
    nbt.startList('BlockStatePalette', 10, 2);
    // Индекс 0 = воздух (белые клетки / проходы)
    nbt.writeStringTag('Name', 'minecraft:air');
    nbt.endCompound();
    // Индекс 1 = глубинносланцевые кирпичи (черные клетки / стены)
    nbt.writeStringTag('Name', wallBlock);
    nbt.endCompound();

    // Битовая упаковка BlockStates:
    // По спецификации Litematica: bits = max(2, ceil(log2(paletteLen))) = 2 бита на блок.
    // Порядок индексов: Index = x + (z * SizeX) + (y * SizeX * SizeZ). При y = 0: x + z * 60.
    // 3600 блоков * 2 бита = 7200 бит -> 113 значений Long (каждое по 32 блока).
    const int longCount = 113;
    final longs = List<int>.filled(longCount, 0);

    for (int z = 0; z < dim; z++) {
      for (int x = 0; x < dim; x++) {
        final int blockIndex = z * dim + x;
        // 0 = воздух, 1 = глубинносланцевые кирпичи
        final int paletteIndex = maze.isPassage(x, z) ? 0 : 1;

        final int longIndex = blockIndex ~/ 32;
        final int bitOffset = (blockIndex % 32) * 2;
        longs[longIndex] |= (paletteIndex << bitOffset);
      }
    }

    nbt.writeLongArrayTag('BlockStates', longs);

    // Пустые списки для сущностей и тиков (требуются спецификацией)
    nbt.startList('Entities', 10, 0);
    nbt.startList('TileEntities', 10, 0);
    nbt.startList('PendingBlockTicks', 10, 0);
    nbt.startList('PendingFluidTicks', 10, 0);

    nbt.endCompound(); // End регион maze_60x60
    nbt.endCompound(); // End Regions
    nbt.endCompound(); // End Root

    // Сжатие NBT в GZip
    final rawNbtBytes = nbt.toBytes();
    final gzippedBytes = gzip.encode(rawNbtBytes);

    return Uint8List.fromList(gzippedBytes);
  }
}

