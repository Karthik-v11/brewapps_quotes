import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<bool> getIsDarkMode();
  Future<void> setIsDarkMode(bool isDarkMode);

  Future<int> getAccentColor();
  Future<void> setAccentColor(int colorValue);

  Future<double> getFontSize();
  Future<void> setFontSize(double fontSize);

  Future<String?> getNotificationTime();
  Future<void> setNotificationTime(String time);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences sharedPreferences;

  static const String keyDarkMode = 'is_dark_mode';
  static const String keyAccentColor = 'accent_color';
  static const String keyFontSize = 'font_size';
  static const String keyNotificationTime = 'notification_time';

  SettingsRepositoryImpl(this.sharedPreferences);

  @override
  Future<bool> getIsDarkMode() async {
    return sharedPreferences.getBool(keyDarkMode) ?? true;
  }

  @override
  Future<void> setIsDarkMode(bool isDarkMode) async {
    await sharedPreferences.setBool(keyDarkMode, isDarkMode);
  }

  @override
  Future<int> getAccentColor() async {
    // Default to deepPurpleAccent (0xFF7C4DFF)
    return sharedPreferences.getInt(keyAccentColor) ?? 0xFF7C4DFF;
  }

  @override
  Future<void> setAccentColor(int colorValue) async {
    await sharedPreferences.setInt(keyAccentColor, colorValue);
  }

  @override
  Future<double> getFontSize() async {
    return sharedPreferences.getDouble(keyFontSize) ?? 18.0;
  }

  @override
  Future<void> setFontSize(double fontSize) async {
    await sharedPreferences.setDouble(keyFontSize, fontSize);
  }

  @override
  Future<String?> getNotificationTime() async {
    return sharedPreferences.getString(keyNotificationTime);
  }

  @override
  Future<void> setNotificationTime(String time) async {
    await sharedPreferences.setString(keyNotificationTime, time);
  }
}
