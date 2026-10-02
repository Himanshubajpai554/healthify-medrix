import '../repositories/file_storage_repository.dart';
import '../../models/report_model.dart';

class MockFileStorageRepository implements FileStorageRepository {
  final Map<String, List<int>> _storage = {};
  final Map<String, DocumentReference> _metadataStore = {};

  @override
  Future<DocumentReference> uploadFile({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    required String category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final id = 'DOC-REF-${DateTime.now().millisecondsSinceEpoch}';
    final key = '$category/${DateTime.now().year}/$fileName';

    final ref = DocumentReference(
      id: id,
      fileName: fileName,
      mimeType: mimeType,
      size: bytes.length,
      storageKey: key,
      createdAt: DateTime.now(),
    );

    _storage[key] = bytes;
    _metadataStore[key] = ref;

    return ref;
  }

  @override
  Future<List<int>> downloadFile(String storageKey) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _storage[storageKey] ?? [0x44, 0x55, 0x4D, 0x4D, 0x59]; // Mock bytes
  }

  @override
  Future<void> deleteFile(String storageKey) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage.remove(storageKey);
    _metadataStore.remove(storageKey);
  }

  @override
  Future<DocumentReference?> getFileMetadata(String storageKey) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _metadataStore[storageKey];
  }
}
