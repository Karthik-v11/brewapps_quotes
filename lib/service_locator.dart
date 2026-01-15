import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quote_vault/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:quote_vault/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quote_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:quote_vault/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/quotes/data/datasources/quote_remote_data_source.dart';
import 'package:quote_vault/features/quotes/data/datasources/user_action_remote_data_source.dart';
import 'package:quote_vault/features/quotes/data/repositories/quote_repository_impl.dart';
import 'package:quote_vault/features/quotes/data/repositories/user_action_repository_impl.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';
import 'package:quote_vault/features/quotes/domain/repositories/user_action_repository.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:quote_vault/core/services/notification_service.dart';
import 'package:quote_vault/core/services/widget_service.dart';
import 'package:quote_vault/core/settings/settings_repository.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      authRepository: sl(),
      loginUseCase: sl(),
      signUpUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Features - Quotes
  // Bloc
  sl.registerFactory(() => QuoteBloc(repository: sl(), widgetService: sl()));
  sl.registerFactory(() => FavoritesBloc(repository: sl()));
  sl.registerFactory(
    () => ThemeBloc(settingsRepository: sl(), notificationService: sl()),
  );

  // Features - Settings
  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<QuoteRepository>(() => QuoteRepositoryImpl(sl()));
  sl.registerLazySingleton<UserActionRepository>(
    () => UserActionRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<QuoteRemoteDataSource>(
    () => QuoteRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserActionRemoteDataSource>(
    () => UserActionRemoteDataSourceImpl(sl()),
  );

  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => WidgetService());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
