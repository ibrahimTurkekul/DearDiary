import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockManager {
  static const _patternKey = 'pattern_hash';
  static const _pinKey = 'pin_hash';
  static const _securityQuestionKey = 'security_question';
  static const _securityAnswerKey = 'security_answer';
  static const _emailKey = 'email_address';
  static const _diaryLockEnabledKey = 'diary_lock_enabled';

  // Şifreleme işlemi - SHA-256 ile hash oluşturma
  String _generateHash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
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

  // Güvenlik sorusu doğrulama
  Future<bool> verifySecurityAnswer(String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_securityAnswerKey);
    final inputHash = _generateHash(answer);
    return savedHash == inputHash;
  }

  // E-posta kaydetme
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  // Kaydedilen e-postayı alma
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> activateDiaryLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_diaryLockEnabledKey, true);
  }

  // Günlük kilidini devre dışı bırakma
  Future<void> deactivateDiaryLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_diaryLockEnabledKey, false);
  }

  // Günlük kilidinin durumu
  Future<bool> isDiaryLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_diaryLockEnabledKey) ?? false;
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

  // Tüm kilit verilerini temizleme
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patternKey);
    await prefs.remove(_pinKey);
    await prefs.remove(_securityQuestionKey);
    await prefs.remove(_securityAnswerKey);
    await prefs.remove(_emailKey);
  }
}