import 'dart:typed_data';

/// Результат операции сохранения файла.
sealed class FileSaveResult {
  const FileSaveResult();
}

/// Успешное сохранение файла.
final class FileSaveSuccess extends FileSaveResult {
  /// Путь или имя сохраненного файла.
  final String path;

  const FileSaveSuccess(this.path);
}

/// Пользователь отменил диалог сохранения.
final class FileSaveCancelled extends FileSaveResult {
  const FileSaveCancelled();
}

/// Произошла ошибка при сохранении.
final class FileSaveFailure extends FileSaveResult {
  /// Текст ошибки.
  final String message;

  const FileSaveFailure(this.message);
}

/// Абстрактный контракт сервиса сохранения файлов.
abstract interface class IFileSaverService {
  /// Сохраняет переданные байты [bytes] в файл с именем [suggestedFileName] и расширением [extension].
  Future<FileSaveResult> saveFile({
    required Uint8List bytes,
    required String suggestedFileName,
    required String extension,
    required String mimeType,
  });
}

