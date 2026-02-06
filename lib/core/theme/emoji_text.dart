import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/emoji_data.dart';

class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow overflow;
  final double? textScaleFactor;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final bool softWrap;

  const EmojiText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);
    final spans = parse(text: text, style: effectiveStyle);

    final textScaler = textScaleFactor != null
        ? TextScaler.linear(textScaleFactor!)
        : MediaQuery.of(context).textScaler;
    return RichText(
      text: TextSpan(style: effectiveStyle, children: spans),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textScaler: textScaler,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      softWrap: softWrap,
    );
  }

  static List<InlineSpan> parse({
    required String text,
    required TextStyle style,
  }) {
    final spans = <InlineSpan>[];
    final fontSize = style.fontSize ?? 14.0;

    for (final char in text.characters) {
      String? assetPath;
      final strippedChar = char.replaceAll('\uFE0F', '');
      if (EmojiData.emojis.containsKey(strippedChar)) {
        assetPath = EmojiData.emojis[strippedChar];
      } else if (EmojiData.emojis.containsKey(char)) {
        assetPath = EmojiData.emojis[char];
      }
      if (assetPath != null) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            baseline: TextBaseline.alphabetic,
            child: Image.asset(
              assetPath,
              width: fontSize,
              height: fontSize,
              key: ValueKey(char),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: char, style: style));
      }
    }
    return spans;
  }
}
