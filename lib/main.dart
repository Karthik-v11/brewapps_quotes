import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import 'package:quote_vault/service_locator.dart' as di;
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/favorites_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:quote_vault/features/splash/presentation/pages/splash_page.dart';
import 'package:quote_vault/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:quote_vault/core/services/notification_service.dart';
import 'package:quote_vault/features/settings/presentation/bloc/theme_bloc.dart';

import 'package:quote_vault/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase first
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialize dependency injection
  await di.init();

  // Initialize Notification Service
  await di.sl<NotificationService>().init();
  // Schedule default daily reminder at 9:00 AM
  await di.sl<NotificationService>().scheduleDailyQuoteNotification(
    hour: 9,
    minute: 0,
  );

  runApp(const QuoteVaultApp());
}

class QuoteVaultApp extends StatefulWidget {
  const QuoteVaultApp({super.key});

  @override
  State<QuoteVaultApp> createState() => _QuoteVaultAppState();
}

class _QuoteVaultAppState extends State<QuoteVaultApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _hideSplashAfterDelay();
  }

  void _hideSplashAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<QuoteBloc>()
            ..add(const FetchQuotesRequested())
            ..add(FetchQuoteOfTheDayRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<FavoritesBloc>()
            ..add(FetchFavoritesRequested())
            ..add(FetchCollectionsRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<ThemeBloc>()..add(ThemeLoadRequested()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Quote Vault',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(
              isDarkMode: false,
              accentColor: themeState.accentColor,
            ),
            darkTheme: AppTheme.getTheme(
              isDarkMode: true,
              accentColor: themeState.accentColor,
            ),
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: _showSplash ? const SplashPage() : const AuthWrapper(),
            routes: {'/onboarding': (context) => const OnboardingPage()},
          );
        },
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.format_quote, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              'QuoteVault',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Welcome to your personal quote companion'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(AuthLogoutRequested()),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
