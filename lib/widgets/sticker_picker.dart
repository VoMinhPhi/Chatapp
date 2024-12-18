import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sticker_provider.dart';
import '../theme/phix_theme.dart';

class StickerPicker extends StatelessWidget {
  final Function(String stickerId) onStickerSelected;

  const StickerPicker({
    super.key,
    required this.onStickerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: DefaultTabController(
        length: context.read<StickerProvider>().categories.length,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              color: Colors.grey[100],
              child: TabBar(
                isScrollable: true,
                labelColor: PhixTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: PhixTheme.primaryColor,
                tabs: context
                    .read<StickerProvider>()
                    .categories
                    .map((category) => Tab(
                      child: Row(
                        children: [
                          _getCategoryIcon(category),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    ))
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: context
                    .read<StickerProvider>()
                    .categories
                    .map((category) => _StickerGrid(
                          category: category,
                          onStickerSelected: onStickerSelected,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Cảm xúc':
        return const Text('😊', style: TextStyle(fontSize: 20));
      case 'Hành động':
        return const Text('👍', style: TextStyle(fontSize: 20));
      case 'Trái tim':
        return const Text('❤️', style: TextStyle(fontSize: 20));
      case 'Động vật':
        return const Text('🐱', style: TextStyle(fontSize: 20));
      case 'Thức ăn':
        return const Text('🍕', style: TextStyle(fontSize: 20));
      case 'Hoạt động':
        return const Text('🎉', style: TextStyle(fontSize: 20));
      default:
        return const Icon(Icons.emoji_emotions);
    }
  }
}

class _StickerGrid extends StatelessWidget {
  final String category;
  final Function(String stickerId) onStickerSelected;

  const _StickerGrid({
    required this.category,
    required this.onStickerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final stickers = context
        .read<StickerProvider>()
        .getStickersByCategory(category);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return InkWell(
          onTap: () => onStickerSelected(sticker.path),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                sticker.path,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 