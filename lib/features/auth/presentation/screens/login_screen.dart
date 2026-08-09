import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/sheets.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).login(_idController.text.trim(), _passwordController.text);
      // Router redirect navigates to /home automatically.
    } on AppFailure catch (e) {
      if (mounted) AppSnack.error(context, e.message);
    } catch (_) {
      if (mounted) AppSnack.error(context, 'Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateId(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Employee ID or email is required';
    if (value.contains('@') && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    if (value.length < 3) return 'Enter a valid employee ID or email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                      child: const Center(
                        child: Text('W', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(AppConstants.companyName, style: theme.textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 40),
                Text('Welcome Back', style: theme.textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your employee account',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _idController,
                        validator: _validateId,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID or Email',
                          prefixIcon: Icon(Icons.badge_outlined),
                          hintText: 'EMP-1024',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        validator: _validatePassword,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: _loading ? 'Signing in…' : 'Login',
                  loading: _loading,
                  onPressed: _submit,
                  icon: Icons.login_rounded,
                ),

                const SizedBox(height: 36),
                Center(
                  child: Text(
                    '© 2026 ${AppConstants.companyName}',
                    style: theme.textTheme.labelMedium?.copyWith(color: AppColors.gray),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}