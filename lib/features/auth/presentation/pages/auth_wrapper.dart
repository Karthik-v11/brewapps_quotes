import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/auth/presentation/pages/login_page.dart';
import 'package:quote_vault/features/home/presentation/pages/home_page.dart';
import 'package:quote_vault/features/splash/presentation/pages/splash_page.dart';

import 'package:quote_vault/features/onboarding/presentation/pages/onboarding_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showOnboarding = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthSignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Signup success: Email confirmation likely required',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const HomePage();
          } else if (state is AuthUnauthenticated ||
              state is AuthError ||
              state is AuthLoading ||
              state is AuthSignUpSuccess) {
            if (_showOnboarding) {
              return OnboardingPage(
                onFinish: () => setState(() => _showOnboarding = false),
              );
            }
            return const LoginPage();
          }
          return const SplashPage();
        },
      ),
    );
  }
}
