import 'package:flutter/material.dart';

import 'app_strings.dart';

/// Keeps constant screen sections reactive when the locale changes.
class LocalizedText extends StatelessWidget {
  const LocalizedText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textDirection,
    this.semanticsLabel,
    this.textScaler,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
  });
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextDirection? textDirection;
  final String? semanticsLabel;
  final TextScaler? textScaler;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) => Text(
    context.tr(data),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
    textDirection: textDirection,
    semanticsLabel: semanticsLabel == null ? null : context.tr(semanticsLabel!),
    textScaler: textScaler,
    strutStyle: strutStyle,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
  );
}
