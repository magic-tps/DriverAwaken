import 'package:flutter/material.dart';

import '../services/account_session.dart';
import '../services/cloud_report_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({
    this.session,
    this.home = const HomeScreen(),
    super.key,
  });
  final AccountSession? session;
  final Widget home;

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  bool _entered = false;
  bool _loading = true;
  bool _decided = false;
  AccountSession get _session => widget.session ?? CloudReportService.instance;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      await _session.initialize();
      if (mounted && !_decided) {
        setState(() {
          _entered = _session.signedIn;
        });
      }
    } catch (_) {
      // Login offers a retry and local use remains available.
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _enter() => setState(() {
    _decided = true;
    _entered = true;
  });

  @override
  Widget build(BuildContext context) {
    if (_entered) return widget.home;
    if (_loading) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('Preparando tu cuenta…'),
                TextButton(
                  onPressed: _enter,
                  child: const Text('Continuar sin cuenta'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return LoginScreen(
      session: _session,
      onAuthenticated: _enter,
      onGuest: _enter,
    );
  }
}
