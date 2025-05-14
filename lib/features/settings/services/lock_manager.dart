import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockManager {
  static const _patternKey = 'pattern_hash';
  static const _pinKey = 'pin_hash';
  static const _lockTypeKey = 'active_lock_type';
  static const _securityQuestionKey = 'security_question';
  static const _securityAnswerKey = 'security_answer';
  static const _emailKey = 'email_address';
  static const _diaryLockEnabledKey = 'diary_lock_enabled';
  static const _patternDimensionKey = 'pattern_dimension';
  static const _fingerprintEnabledKey = 'fingerprint_enabled';

  late final SharedPreferences _prefs;

  LockManager() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool _isAuthenticated = false; // Kullanıcı doğrulama durumu

  // Doğrulama durumunu kontrol et
  bool get isAuthenticated => _isAuthenticated;

  // Doğrulama durumunu ayarla
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
  }

  // Şifreleme işlemi - SHA-256 ile hash oluşturma
  String _generateHash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  // Aktif kilit türünü kaydetme
  Future<void> setActiveLockType(String lockType) async {
    if (lockType.isEmpty) {
      throw ArgumentError("lockType boş olamaz");
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lockTypeKey, lockType);
  }

  // Aktif kilit türünü okuma
  Future<String?> getActiveLockType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lockTypeKey);
  }

  // Desen kaydetme
  Future<void> savePattern(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _generateHash(pattern.join());
    await prefs.setString(_patternKey, hash);
  }

  // Deseni doğrulama
  Future<bool> verifyPattern(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_patternKey);
    final inputHash = _generateHash(pattern.join());
    return savedHash == inputHash;
  }

  // Desen boyutunu kaydetme
  Future<void> savePatternDimension(int dimension) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_patternDimensionKey, dimension);
  }

  // Desen boyutunu alma
  Future<int?> getPatternDimension() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_patternDimensionKey); // Kaydedilen boyutu döndür
  }

  // PIN kaydetme
  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _generateHash(pin);
    await prefs.setString(_pinKey, hash);
  }

  // PIN doğrulama
  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_pinKey);
    final inputHash = _generateHash(pin);
    return savedHash == inputHash;
  }

  // Güvenlik sorusu ve cevabını kaydetme
  Future<void> saveSecurityQuestion(String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_securityQuestionKey, question);
    final hash = _generateHash(answer);
    await prefs.setString(_securityAnswerKey, hash);
  }

  // Güvenlik sorusunu alma
  Future<String?> getSecurityQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_securityQuestionKey); // Güvenlik sorusunu döndür
  }

  // Güvenlik cevabının hash'ini alma
  Future<String?> getSecurityAnswerHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      _securityAnswerKey,
    ); // Güvenlik cevabının hash'ini döndür
  }

  // Güvenlik sorusu doğrulama
  Future<bool> verifySecurityAnswer(String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_securityAnswerKey);
    final inputHash = _generateHash(answer);
    return savedHash == inputHash;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  // E-posta kaydetme
  Future<void> saveEmail(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw ArgumentError("Geçersiz e-posta adresi");
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
    } catch (e) {
      print("E-posta kaydedilirken bir hata oluştu: $e");
    }
  }

  // Kaydedilen e-postayı alma
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> activateDiaryLock() async {
    await setDiaryLockEnabled(true);
  }

  // Günlük kilidini devre dışı bırakma
  Future<void> deactivateDiaryLock() async {
    await setDiaryLockEnabled(false);
  }

  // Günlük kilidinin durumu
  Future<bool> isDiaryLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_diaryLockEnabledKey) ?? false;
  }

  Future<void> setDiaryLockEnabled(bool isEnabled) async {
    // Belleğe günlük kilidi durumunu kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_diaryLockEnabledKey, isEnabled);
  }

  // Kayıtlı bir desen olup olmadığını kontrol et
  Future<bool> isPatternSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_patternKey);
  }

  // Kayıtlı bir PIN olup olmadığını kontrol et
  Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  // Parmak izi toggle durumunu kontrol et
  Future<bool> isFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fingerprintEnabledKey) ?? false;
  }

  // Tüm kilit verilerini temizleme
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patternKey);
    await prefs.remove(_pinKey);
    await prefs.remove(_securityQuestionKey);
    await prefs.remove(_securityAnswerKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_lockTypeKey);
    await prefs.remove(_diaryLockEnabledKey);
    await prefs.remove(_patternDimensionKey);
    await prefs.remove(_fingerprintEnabledKey);

    print("Tüm kilit verileri temizlendi.");
  }
}
