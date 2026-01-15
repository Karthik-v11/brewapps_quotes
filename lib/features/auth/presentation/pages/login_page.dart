import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/auth/presentation/pages/signup_page.dart';
import 'package:quote_vault/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:quote_vault/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:quote_vault/features/home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Header Section
                    const Text(
                      '”', // Quotation marks icon
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.white,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Log in to your QuoteVault account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 60),
                    // Input Fields
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF6B7280),
                        size: 24,
                      ),
                      validator: (value) =>
                          (value == null || !value.contains('@'))
                          ? 'Invalid email'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Enter password'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Submit Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton(
                            onPressed: state is AuthLoading ? null : _onLogin,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Bottom Link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
