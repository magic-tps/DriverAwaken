import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: LocaleController.instance,
    builder: (context, _) => DropdownButtonFormField<String>(
      key: ValueKey('language-${LocaleController.instance.selection}'),
      initialValue: LocaleController.instance.selection,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: context.tr('Idioma / Language'),
        prefixIcon: const Icon(Icons.language),
      ),
      items: [
        DropdownMenuItem(
          value: 'system',
          child: Text(context.tr('Idioma del teléfono')),
        ),
        const DropdownMenuItem(value: 'es', child: Text('Español')),
        const DropdownMenuItem(value: 'en', child: Text('English')),
      ],
      onChanged: (value) async {
        if (value == null) return;
        try {
          await LocaleController.instance.select(value);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr(
                    'No se pudo guardar el idioma. Inténtalo de nuevo.',
                  ),
                ),
              ),
            );
          }
        }
      },
    ),
  );
}
