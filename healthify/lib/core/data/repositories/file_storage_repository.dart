import '../../models/report_model.dart';

/// Abstract contract for File & Document Storage operations
abstract class FileStorageRepository {
  Future<DocumentReference> uploadFile({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    required String category,
  });

  Future<List<int>> downloadFile(String storageKey);
  Future<void> deleteFile(String storageKey);
  Future<DocumentReference?> getFileMetadata(String storageKey);
}
