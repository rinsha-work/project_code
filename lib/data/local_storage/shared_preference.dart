import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _kUserLoggedIn = 'logged_in';
  static const String _kUserName = 'user_name';
  static const String _kUserUid = 'user_uid';
  static const String _kDietryRestriction = 'dietry_restriction';
  static const String _kEmail = 'email';
  static const String _kPreferredCuisine = 'preferred_cuisine';
  static SharedPreferencesService? _instance;
  static late SharedPreferences _preferences;

  SharedPreferencesService._();

  static Future<SharedPreferencesService> getInstance() async {
    _instance ??= SharedPreferencesService._();
    _preferences = await SharedPreferences.getInstance();
    return _instance!;
  }

  String get userName => _getData(_kUserName) ?? "";

  String get userUid => _getData(_kUserUid) ?? "";

  String get dietryRestriction => _getData(_kDietryRestriction) ?? "";

  String get email => _getData(_kEmail) ?? "";

  String get preferredCuisine => _getData(_kPreferredCuisine) ?? "";

  bool get userLoggedInFlag => _getData(_kUserLoggedIn) ?? false;

  set userLoggedInFlag(bool value) {
    _saveData(_kUserLoggedIn, value);
  }

  set userName(String value) {
    _saveData(_kUserName, value);
  }

  set userUid(String value) {
    _saveData(_kUserUid, value);
  }

  set dietryRestriction(String value) {
    _saveData(_kDietryRestriction, value);
  }

  set email(String value) {
    _saveData(_kEmail, value);
  }

  set preferredCuisine(String value) {
    _saveData(_kPreferredCuisine, value);
  }

  dynamic _getData(String key) {
    var value = _preferences.get(key);
    debugPrint('Retrieved $key: $value');
    return value;
  }

  void _saveData(String key, dynamic value) {
    debugPrint('Saving $key: $value');
    if (value is String) {
      _preferences.setString(key, value);
    } else if (value is int) {
      _preferences.setInt(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is List<String>) {
      _preferences.setStringList(key, value);
    }
  }

  Future<bool> clearData() async {
    final isCleared = await _preferences.clear();
    debugPrint('Cleared : $isCleared');
    return isCleared;
  }
}
