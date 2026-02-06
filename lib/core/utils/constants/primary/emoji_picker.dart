import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/primary/emoji_category.dart';

class EmojiPicker extends StatefulWidget {
  final void Function(String emoji) onEmojiSelected;

  const EmojiPicker({super.key, required this.onEmojiSelected});

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiItem {
  final String base;
  final List<String> variants;

  _EmojiItem(this.base, this.variants);
}

class _EmojiPickerState extends State<EmojiPicker> {
  late PageController _pageController;
  int selectedCategory = 0;

  // Key: Base Emoji, Value: Selected Variant
  final Map<String, String> _preferredSkinTones = {};

  late List<List<_EmojiItem>> _processedCategories;
  late List<EmojiCategory> _availableCategories;

  // Unicode skin tone modifiers
  static const List<int> _modifiers = [
    0x1F3FB,
    0x1F3FC,
    0x1F3FD,
    0x1F3FE,
    0x1F3FF,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedCategory);
    _availableCategories = emojiCategories
        .where((c) => c.emojis != null)
        .toList();
    _processCategories();
  }

  void _processCategories() {
    _processedCategories = _availableCategories.map((category) {
      final rawEmojis = category.emojis!;
      final Map<String, List<String>> groups = {};
      final List<String> order = [];

      for (final emoji in rawEmojis) {
        final base = _stripSkinTone(emoji);
        if (!groups.containsKey(base)) {
          groups[base] = [];
          order.add(base);
        }
        groups[base]!.add(emoji);
      }

      return order.map((base) => _EmojiItem(base, groups[base]!)).toList();
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryTapped(int index) {
    setState(() {
      selectedCategory = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _stripSkinTone(String emoji) {
    final runes = emoji.runes.where((rune) => !_modifiers.contains(rune));
    return String.fromCharCodes(runes);
  }

  void _onEmojiTap(String baseEmoji) {
    final current = _preferredSkinTones[baseEmoji] ?? baseEmoji;
    widget.onEmojiSelected(current);
  }

  void _onEmojiLongPress(
    LongPressStartDetails details,
    String baseEmoji,
    List<String> variants,
  ) async {
    if (variants.length <= 1) return; // No variants to show

    // Show menu logic
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      color: ColorsManager.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: variants.map((variant) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.of(context).pop(variant),
                      child: EmojiText(
                        text: variant,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );

    if (selected != null) {
      setState(() {
        _preferredSkinTones[baseEmoji] = selected;
      });
      widget.onEmojiSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.cardColor,
        border: Border(
          top: BorderSide(
            color: ColorsManager.cardColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER: Categories
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableCategories.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (_, i) {
                final isActive = i == selectedCategory;
                return GestureDetector(
                  onTap: () => _onCategoryTapped(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? ColorsManager.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Center(
                      child: EmojiText(
                        text: _availableCategories[i].icon,
                        style: TextStylesManager.regular24.copyWith(
                          fontSize: 22,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // PageView for emojis
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _processedCategories.length,
              onPageChanged: (index) {
                setState(() {
                  selectedCategory = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildEmojiGrid(_processedCategories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid(List<_EmojiItem> emojiItems) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: emojiItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        final item = emojiItems[i];
        final displayEmoji = _preferredSkinTones[item.base] ?? item.base;
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            onLongPressStart: (details) =>
                _onEmojiLongPress(details, item.base, item.variants),
            child: InkResponse(
              radius: 28,
              onTap: () => _onEmojiTap(item.base),
              child: Center(
                child: EmojiText(
                  text: displayEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
