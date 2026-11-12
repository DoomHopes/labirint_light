import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/interfaces/i_file_saver_service.dart';

/// Реализация сервиса сохранения файлов с поддержкой системного диалога и резервного сохранения.
final class FileSaverServiceImpl implements IFileSaverService {
  const FileSaverServiceImpl();

  @override
  Future<FileSaveResult> saveFile({
    required Uint8List bytes,
    required String suggestedFileName,
    required String extension,
    required String mimeType,
  }) async {
    try {
      // 1. Попытка вызова системного диалога сохранения через FilePicker
      final Uri? savedUri = await FilePicker.saveFile(
        dialogTitle: 'Сохранить лабиринт 60x60',
        fileName: '$suggestedFileName.$extension',
        bytes: bytes,
        mimeType: mimeType,
      );

      // Если пользователь отменил диалог
      if (savedUri == null) {
        return const FileSaveCancelled();
      }

      return FileSaveSuccess(savedUri.toFilePath());
    } catch (e) {
      // Резервный путь: попытка сохранить напрямую в папку Загрузки (Downloads)
      try {
        final Directory? downloadsDir = await getDownloadsDirectory();
        final Directory targetDir = downloadsDir ?? await getApplicationDocumentsDirectory();
        final String fallbackPath =
            '${targetDir.path}${Platform.pathSeparator}$suggestedFileName.$extension';

        final file = File(fallbackPath);
        await file.writeAsBytes(bytes, flush: true);

        return FileSaveSuccess(file.path);
      } catch (fallbackError) {
        return FileSaveFailure(
          'Не удалось сохранить файл: $e (Резервная попытка: $fallbackError)',
        );
      }
    }
  }
}
