import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/settings/settings_repository.dart';
import 'package:quote_vault/core/services/notification_service.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeLoadRequested extends ThemeEvent {}

class ThemeToggleRequested extends ThemeEvent {
  final bool isDarkMode;
  const ThemeToggleRequested(this.isDarkMode);
  @override
  List<Object?> get props => [isDarkMode];
}

class ThemeAccentColorChanged extends ThemeEvent {
  final Color color;
  const ThemeAccentColorChanged(this.color);
  @override
  List<Object?> get props => [color];
}

class ThemeFontSizeChanged extends ThemeEvent {
  final double fontSize;
  const ThemeFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class ThemeNotificationTimeChanged extends ThemeEvent {
  final String time; // HH:mm format
  const ThemeNotificationTimeChanged(this.time);
  @override
  List<Object?> get props => [time];
}

// States
class ThemeState extends Equatable {
  final bool isDarkMode;
  final Color accentColor;
  final double fontSize;
  final String notificationTime;

  const ThemeState({
    required this.isDarkMode,
    required this.accentColor,
    required this.fontSize,
    required this.notificationTime,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      isDarkMode: true,
      accentColor: Color(0xFF7C4DFF),
      fontSize: 18.0,
      notificationTime: '09:00',
    );
  }

  ThemeState copyWith({
    bool? isDarkMode,
    Color? accentColor,
    double? fontSize,
    String? notificationTime,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColor: accentColor ?? this.accentColor,
      fontSize: fontSize ?? this.fontSize,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  @override
  List<Object?> get props => [
    isDarkMode,
    accentColor,
    fontSize,
    notificationTime,
  ];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;

  ThemeBloc({
    required SettingsRepository settingsRepository,
    required NotificationService notificationService,
  }) : _settingsRepository = settingsRepository,
       _notificationService = notificationService,
       super(ThemeState.initial()) {
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeToggleRequested>(_onThemeToggleRequested);
    on<ThemeAccentColorChanged>(_onThemeAccentColorChanged);
    on<ThemeFontSizeChanged>(_onThemeFontSizeChanged);
    on<ThemeNotificationTimeChanged>(_onThemeNotificationTimeChanged);
  }

  Future<void> _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final isDarkMode = await _settingsRepository.getIsDarkMode();
    final accentColorVal = await _settingsRepository.getAccentColor();
    final fontSize = await _settingsRepository.getFontSize();
    final notificationTime =
        await _settingsRepository.getNotificationTime() ?? '09:00';

    emit(
      ThemeState(
        isDarkMode: isDarkMode,
        accentColor: Color(accentColorVal),
        fontSize: fontSize,
        notificationTime: notificationTime,
      ),
    );

    // Schedule on load
    _schedule(notificationTime);
  }

  Future<void> _onThemeToggleRequested(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    await _settingsRepository.setIsDarkMode(event.isDarkMode);
    emit(state.copyWith(isDarkMode: event.isDarkMode));
  }

  Future<void> _onThemeAccentColorChanged(
    ThemeAccentColorChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _settingsRepository.setAccentColor(event.color.value);
    emit(state.copyWith(accentColor: event.color));
  }

  Future<void> _onThemeFontSizeChanged(
    ThemeFontSizeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _settingsRepository.setFontSize(event.fontSize);
    emit(state.copyWith(fontSize: event.fontSize));
  }

  Future<void> _onThemeNotificationTimeChanged(
    ThemeNotificationTimeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _settingsRepository.setNotificationTime(event.time);
    emit(state.copyWith(notificationTime: event.time));
    _schedule(event.time);
  }

  void _schedule(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      _notificationService.scheduleDailyQuoteNotification(
        hour: hour,
        minute: minute,
      );
    }
  }
}
