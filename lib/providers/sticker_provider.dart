import 'package:flutter/material.dart';
import '../models/sticker.dart';

class StickerProvider with ChangeNotifier {
  final List<Sticker> _stickers = [
    // Emoji cảm xúc cơ bản
    Sticker(id: 'smile', path: '😊', category: 'Cảm xúc'),
    Sticker(id: 'laugh', path: '😂', category: 'Cảm xúc'),
    Sticker(id: 'love', path: '😍', category: 'Cảm xúc'),
    Sticker(id: 'sad', path: '😢', category: 'Cảm xúc'),
    Sticker(id: 'angry', path: '😠', category: 'Cảm xúc'),
    Sticker(id: 'wink', path: '😉', category: 'Cảm xúc'),
    Sticker(id: 'cool', path: '😎', category: 'Cảm xúc'),
    Sticker(id: 'crazy', path: '🤪', category: 'Cảm xúc'),
    Sticker(id: 'worried', path: '😟', category: 'Cảm xúc'),
    Sticker(id: 'surprised', path: '😮', category: 'Cảm xúc'),

    // Emoji hành động
    Sticker(id: 'thumbs_up', path: '👍', category: 'Hành động'),
    Sticker(id: 'thumbs_down', path: '👎', category: 'Hành động'),
    Sticker(id: 'clap', path: '👏', category: 'Hành động'),
    Sticker(id: 'wave', path: '👋', category: 'Hành động'),
    Sticker(id: 'pray', path: '🙏', category: 'Hành động'),
    Sticker(id: 'muscle', path: '💪', category: 'Hành động'),
    Sticker(id: 'punch', path: '👊', category: 'Hành động'),
    Sticker(id: 'ok', path: '👌', category: 'Hành động'),
    Sticker(id: 'victory', path: '✌️', category: 'Hành động'),
    Sticker(id: 'handshake', path: '🤝', category: 'Hành động'),

    // Emoji trái tim
    Sticker(id: 'heart', path: '❤️', category: 'Trái tim'),
    Sticker(id: 'broken_heart', path: '💔', category: 'Trái tim'),
    Sticker(id: 'sparkle_heart', path: '💖', category: 'Trái tim'),
    Sticker(id: 'blue_heart', path: '💙', category: 'Trái tim'),
    Sticker(id: 'green_heart', path: '💚', category: 'Trái tim'),
    Sticker(id: 'yellow_heart', path: '💛', category: 'Trái tim'),
    Sticker(id: 'purple_heart', path: '💜', category: 'Trái tim'),
    Sticker(id: 'black_heart', path: '🖤', category: 'Trái tim'),
    Sticker(id: 'gift_heart', path: '💝', category: 'Trái tim'),
    Sticker(id: 'heart_eyes', path: '😍', category: 'Trái tim'),

    // Emoji động vật
    Sticker(id: 'cat', path: '🐱', category: 'Động vật'),
    Sticker(id: 'dog', path: '🐶', category: 'Động vật'),
    Sticker(id: 'rabbit', path: '🐰', category: 'Động vật'),
    Sticker(id: 'bear', path: '🐻', category: 'Động vật'),
    Sticker(id: 'panda', path: '🐼', category: 'Động vật'),
    Sticker(id: 'penguin', path: '🐧', category: 'Động vật'),
    Sticker(id: 'monkey', path: '🐵', category: 'Động vật'),
    Sticker(id: 'unicorn', path: '🦄', category: 'Động vật'),
    Sticker(id: 'butterfly', path: '🦋', category: 'Động vật'),
    Sticker(id: 'dolphin', path: '🐬', category: 'Động vật'),

    // Emoji thức ăn
    Sticker(id: 'pizza', path: '🍕', category: 'Thức ăn'),
    Sticker(id: 'burger', path: '🍔', category: 'Thức ăn'),
    Sticker(id: 'fries', path: '🍟', category: 'Thức ăn'),
    Sticker(id: 'sushi', path: '🍣', category: 'Thức ăn'),
    Sticker(id: 'ice_cream', path: '🍦', category: 'Thức ăn'),
    Sticker(id: 'cake', path: '🎂', category: 'Thức ăn'),
    Sticker(id: 'coffee', path: '☕', category: 'Thức ăn'),
    Sticker(id: 'beer', path: '🍺', category: 'Thức ăn'),
    Sticker(id: 'wine', path: '🍷', category: 'Thức ăn'),
    Sticker(id: 'fruits', path: '🍎', category: 'Thức ăn'),

    // Emoji hoạt động
    Sticker(id: 'party', path: '🎉', category: 'Hoạt động'),
    Sticker(id: 'gift', path: '🎁', category: 'Hoạt động'),
    Sticker(id: 'music', path: '🎵', category: 'Hoạt động'),
    Sticker(id: 'sport', path: '⚽', category: 'Hoạt động'),
    Sticker(id: 'game', path: '🎮', category: 'Hoạt động'),
    Sticker(id: 'movie', path: '🎬', category: 'Hoạt động'),
    Sticker(id: 'book', path: '📚', category: 'Hoạt động'),
    Sticker(id: 'art', path: '🎨', category: 'Hoạt động'),
    Sticker(id: 'camera', path: '📷', category: 'Hoạt động'),
    Sticker(id: 'travel', path: '✈️', category: 'Hoạt động'),
  ];

  List<Sticker> get stickers => _stickers;

  List<String> get categories => 
      _stickers.map((s) => s.category).toSet().toList();

  List<Sticker> getStickersByCategory(String category) =>
      _stickers.where((s) => s.category == category).toList();
} 