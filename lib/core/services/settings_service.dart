import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todotask/core/constants/hive_constants.dart';

abstract class SettingsService {
  Future<ThemeMode> getThemeMode();

  Future<void> setThemeMode(ThemeMode mode);
}

class SettingsServiceImpl implements SettingsService {
  SettingsServiceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<ThemeMode> getThemeMode() async {
    final value = _box.get(HiveConstants.themeModeKey) as String?;
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await _box.put(HiveConstants.themeModeKey, value);
  }
}

Future<Box<dynamic>> openSettingsBox() async {
  return Hive.openBox(HiveConstants.settingsBox);
}
