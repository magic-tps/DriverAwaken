import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'messages.dart';

/// Localizes display text, including Spanish descriptions in existing reports.
/// Stored event codes, user content and Firebase document fields stay unchanged.
class AppStrings {
  const AppStrings(this.languageCode);
  final String languageCode;
  static const delegate = _StringsDelegate();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      const AppStrings('es');

  static final _exact = <String, String>{
    ...englishMessages,
    for (final entry in englishMessages.entries)
      entry.key.toUpperCase(): entry.value.toUpperCase(),
  };
  static final _templates =
      _exact.entries
          .where(
            (entry) =>
                entry.key != entry.value &&
                RegExp(r'\{\d+\}').hasMatch(entry.key),
          )
          .map(_MessageTemplate.new)
          .toList()
        ..sort((a, b) => b.literalLength.compareTo(a.literalLength));

  String translate(String text) => _translate(text, 0);

  String _translate(String text, int depth) {
    if (languageCode != 'en') return spanishCorrections[text] ?? text;
    final exact = _exact[text];
    if (exact != null) return exact;
    if (depth > 4) return text;
    for (final template in _templates) {
      final match = template.pattern.firstMatch(text);
      if (match == null) continue;
      return template.english.replaceAllMapped(RegExp(r'\{(\d+)\}'), (slot) {
        final index = template.slots.indexOf(int.parse(slot[1]!));
        return index < 0 ? slot[0]! : _translate(match[index + 1]!, depth + 1);
      });
    }
    return text;
  }
}

class _MessageTemplate {
  _MessageTemplate(MapEntry<String, String> entry) : english = entry.value {
    final source = entry.key;
    var end = 0;
    final expression = StringBuffer('^');
    for (final slot in RegExp(r'\{(\d+)\}').allMatches(source)) {
      final literal = source.substring(end, slot.start);
      literalLength += literal.length;
      expression.write(RegExp.escape(literal));
      expression.write('(.*?)');
      slots.add(int.parse(slot[1]!));
      end = slot.end;
    }
    literalLength += source.length - end;
    expression.write(RegExp.escape(source.substring(end)));
    expression.write(r'$');
    pattern = RegExp(expression.toString(), dotAll: true);
  }
  final String english;
  final slots = <int>[];
  int literalLength = 0;
  late final RegExp pattern;
}

class _StringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _StringsDelegate();
  @override
  bool isSupported(Locale locale) => ['es', 'en'].contains(locale.languageCode);
  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture(AppStrings(locale.languageCode));
  @override
  bool shouldReload(_StringsDelegate old) => false;
}

extension TranslatedContext on BuildContext {
  String tr(String text) => AppStrings.of(this).translate(text);
}
