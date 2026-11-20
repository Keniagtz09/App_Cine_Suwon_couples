import 'package:flutter/material.dart';

import '../core/theme/irworobongdo_theme.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (_isLoginMode) {
        await _authService.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.registerWithEmail(
          displayName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.movie_filter_rounded,
                    size: 52,
                    color: IrworobongdoColors.vermilion,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cine Suwon · 수원 영화',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLoginMode
                        ? 'Inicia sesión para entrar a tu sala privada'
                        : 'Crea tu cuenta para compartir películas y charlas',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!_isLoginMode) ...[
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre o apodo',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    color: IrworobongdoColors.mutedIvory,
                                  ),
                                ),
                                validator: (value) {
                                  if (_isLoginMode) return null;
                                  if (value == null ||
                                      value.trim().length < 2) {
                                    return 'Ingresa un nombre de al menos 2 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(
                                  Icons.mail_outline_rounded,
                                  color: IrworobongdoColors.mutedIvory,
                                ),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty || !text.contains('@')) {
                                  return 'Ingresa un correo electrónico válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: IrworobongdoColors.mutedIvory,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: IrworobongdoColors.mutedIvory,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: IrworobongdoColors.vermilion
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: IrworobongdoColors.vermilion
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: IrworobongdoColors.ivory,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: IrworobongdoColors.ivory,
                                      ),
                                    )
                                  : Text(
                                      _isLoginMode
                                          ? 'Iniciar sesión'
                                          : 'Crear cuenta',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _isSubmitting ? null : _toggleMode,
                    child: Text(
                      _isLoginMode
                          ? '¿Aún no tienes cuenta? Regístrate aquí'
                          : '¿Ya tienes cuenta? Inicia sesión',
                      style: textTheme.bodyMedium?.copyWith(
                        color: IrworobongdoColors.warmGold,
                      ),
                    ),
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