import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/theme/text_styles.dart';

class ScrollableCaption extends StatefulWidget {
  final String? text;
  const ScrollableCaption({super.key, this.text});

  @override
  State<ScrollableCaption> createState() => ScrollableCaptionState();
}

class ScrollableCaptionState extends State<ScrollableCaption> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text == null || widget.text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: expanded ? 220 : 60),
        child: SingleChildScrollView(
          physics: expanded
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: EmojiText(
            text: widget.text!,
            style: TextStylesManager.regular14.copyWith(
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
