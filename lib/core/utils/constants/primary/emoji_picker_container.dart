import 'package:flutter/material.dart';
import 'package:skilltok/core/utils/constants/primary/emoji_picker.dart';

class EmojiPickerContainer extends StatelessWidget {
  final bool isVisible;
  final TextEditingController controller;

  const EmojiPickerContainer({
    super.key,
    required this.isVisible,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: isVisible ? 320 : 0,
      child: isVisible
          ? EmojiPicker(
              onEmojiSelected: (emoji) {
                final text = controller.text;
                final selection = controller.selection;

                final newText = text.replaceRange(
                  selection.start,
                  selection.end,
                  emoji,
                );

                controller
                  ..text = newText
                  ..selection = TextSelection.collapsed(
                    offset: selection.start + emoji.length,
                  );
              },
            )
          : const SizedBox.shrink(),
    );
  }
}
