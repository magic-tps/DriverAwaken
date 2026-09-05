import 'package:flutter/material.dart';

import '../services/account_session.dart';
import '../services/cloud_report_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onAuthenticated,
    this.onGuest,
    this.session,
    super.key,
  });
  final VoidCallback onAuthenticated;
  final VoidCallback? onGuest;
  final AccountSession? session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _obscure = true;
  bool _error = false;
  String? _message;
  AccountSession get _session => widget.session ?? CloudReportService.instance;

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _session.signIn(
        _email.text.trim(),
        _password.text,
        register: _register,
      );
      if (!mounted) return;
      _password.clear();
      _confirmation.clear();
      widget.onAuthenticated();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = true;
          _message = CloudReportService.friendlyError(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _reset() async {
    if (!_email.text.contains('@')) {
      setState(() {
        _error = true;
        _message = 'Escribe tu correo para recuperar la contraseña.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _session.resetPassword(_email.text);
      if (mounted) {
        setState(() {
          _error = false;
          _message =
              'Si existe una cuenta, recibirás instrucciones en tu correo.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = true;
          _message = CloudReportService.friendlyError(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.onGuest == null
        ? AppBar(title: const Text('Tu cuenta'))
        : null,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AutofillGroup(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/logo.png', width: 46, height: 46),
                        const SizedBox(width: 12),
                        const Text(
                          'DriverAwaken',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF28C9FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      _register ? 'Crea tu cuenta' : 'Bienvenido de nuevo',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Guarda tus informes en tu cuenta y consúltalos cuando los necesites.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Iniciar sesión'),
                        ),
                        ButtonSegment(value: true, label: Text('Crear cuenta')),
                      ],
                      selected: {_register},
                      onSelectionChanged: _busy
                          ? null
                          : (value) => setState(() {
                              _register = value.single;
                              _message = null;
                              _confirmation.clear();
                              _form.currentState?.reset();
                            }),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      key: const ValueKey('login-email'),
                      controller: _email,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) =>
                          RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch(value?.trim() ?? '')
                          ? null
                          : 'Introduce un correo válido.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('login-password'),
                      controller: _password,
                      enabled: !_busy,
                      obscureText: _obscure,
                      enableSuggestions: false,
                      autocorrect: false,
                      autofillHints: [
                        _register
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      onFieldSubmitted: (_) {
                        if (!_register) _submit();
                      },
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () => setState(() {
                            _obscure = !_obscure;
                          }),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.isEmpty ?? true)
                          ? 'Introduce tu contraseña.'
                          : _register && value!.length < 6
                          ? 'Usa al menos 6 caracteres.'
                          : null,
                    ),
                    if (_register) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('login-confirmation'),
                        controller: _confirmation,
                        enabled: !_busy,
                        obscureText: _obscure,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Repite tu contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) => value == _password.text
                            ? null
                            : 'Las contraseñas no coinciden.',
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tu correo identifica tu cuenta. Los informes se suben solo cuando lo confirmas.',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ] else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _busy ? null : _reset,
                          child: const Text('Olvidé mi contraseña'),
                        ),
                      ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _error
                                ? const Color(0xFFFFB36B)
                                : const Color(0xFF24D17E),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const ValueKey('login-submit'),
                      onPressed: _busy ? null : _submit,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward),
                      label: Text(
                        _busy
                            ? 'Conectando…'
                            : _register
                            ? 'Crear mi cuenta'
                            : 'Entrar a mi cuenta',
                      ),
                    ),
                    if (widget.onGuest != null) ...[
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: _busy ? null : widget.onGuest,
                        child: const Text('Continuar sin cuenta'),
                      ),
                      const Text(
                        'Sin cuenta, tus viajes se guardan solo en este teléfono.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
