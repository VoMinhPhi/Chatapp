enum FriendshipStatus {
  pending,    // Đang chờ chấp nhận
  accepted,   // Đã chấp nhận
  declined    // Đã từ chối
}

class Friendship {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendshipStatus status;
  final DateTime createdAt;

  Friendship({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });
} 