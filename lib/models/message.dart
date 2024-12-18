enum MessageType { text, sticker }
enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final String? groupId;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final bool isRead;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    this.groupId,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.isRead = false,
  });

  Message copyWith({
    MessageStatus? status,
    bool? isRead,
  }) {
    return Message(
      id: id,
      content: content,
      senderId: senderId,
      receiverId: receiverId,
      groupId: groupId,
      timestamp: timestamp,
      type: type,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
    );
  }
} 