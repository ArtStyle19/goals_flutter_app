import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/core/utils/validators.dart';
import 'package:productivity/core/widgets/async_value_widgets.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/presentation/state/auth_provider.dart';
import 'package:productivity/features/auth/presentation/widgets/password_field.dart';

/// Registration page with name, email, password form.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

    if (success && mounted) {
      context.go(AppRoutes.goals);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final isLoading = authAsync.isLoading;

    // Listen for errors
    ref.listen<AsyncValue<UserEntity?>>(authProvider, (_, next) {
      next.showErrorSnackbar(context);
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Header ────────────────────────────
                  Icon(
                    Icons.rocket_launch_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crea tu cuenta',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comienza a planificar tu productividad',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ─── Name ──────────────────────────────
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => Validators.required(v, 'El nombre'),
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Email ─────────────────────────────
                  TextFormField(
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Password ──────────────────────────
                  PasswordField(
                    controller: _passwordController,
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // ─── Confirm Password ──────────────────
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Contraseña',
                    validator: (v) =>
                        Validators.confirmPassword(v, _passwordController.text),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onRegister(),
                  ),
                  const SizedBox(height: 24),

                  // ─── Register Button ───────────────────
                  FilledButton(
                    onPressed: isLoading ? null : _onRegister,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Crear Cuenta'),
                  ),
                  const SizedBox(height: 16),

                  // ─── Login Link ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta?'),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go(AppRoutes.login),
                        child: const Text('Inicia Sesión'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
