import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    required this.email,
    required this.onLogin,
    required this.onCloud,
    super.key,
  });
  final String? email;
  final VoidCallback onLogin;
  final VoidCallback onCloud;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0C2030),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF28C9FF).withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              email == null
                  ? Icons.account_circle_outlined
                  : Icons.verified_user_outlined,
              color: const Color(0xFF28C9FF),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email == null
                        ? 'Estás usando la app sin cuenta'
                        : 'Sesión iniciada',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    email ?? 'Tus informes se guardan solo en este teléfono.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (email == null)
          FilledButton.icon(
            onPressed: onLogin,
            icon: const Icon(Icons.login),
            label: const Text('Iniciar sesión / Crear cuenta'),
          )
        else
          FilledButton.icon(
            onPressed: onCloud,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Subir informes a la nube'),
          ),
        if (email != null)
          TextButton(
            onPressed: onCloud,
            child: const Text('Ver informes guardados y mi cuenta'),
          ),
      ],
    ),
  );
}
