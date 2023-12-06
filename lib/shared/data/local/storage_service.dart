abstract class StorageService {
  void init(String identifier);

  bool get hasInitialized;

  Future<bool> set(String key, String data);

  Future<Object?> get(String key);
}
