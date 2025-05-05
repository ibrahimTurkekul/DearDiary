import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> savePatternHash(String hash) async {
    await _secureStorage.write(key: 'pattern_hash', value: hash);
  }

  Future<String?> getPatternHash() async {
    return await _secureStorage.read(key: 'pattern_hash');
  }

  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: 'pin', value: pin);
  }

  Future<String?> getPin() async {
    return await _secureStorage.read(key: 'pin');
  }
}