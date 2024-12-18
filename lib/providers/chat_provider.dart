import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/auth_user.dart';
import '../models/friendship.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  final List<User> _users = [];
  String? _currentUserId;
  String? _selectedUserId;
  final List<Group> _groups = [];
  String? _selectedGroupId;
  final List<Friendship> _friendships = [];
  final Set<String> _blockedUsers = {};
  final Set<String> _mutedUsers = {};
  final Map<String, DateTime> _typingUsers = {};
  String _searchQuery = '';

  // Getters
  List<User> get users => friends;
  List<User> get allUsers => _users.where((user) => user.id != _currentUserId).toList();
  String? get currentUserId => _currentUserId;
  String? get selectedUserId => _selectedUserId;
  String? get selectedGroupId => _selectedGroupId;

  // Lấy danh sách nhóm của người dùng hiện tại
  List<Group> get groups => _groups
      .where((group) => group.memberIds.contains(_currentUserId))
      .toList();

  // Lấy danh sách tin nhắn của nhóm hoặc chat 1-1
  List<Message> get messages {
    List<Message> filteredMessages;
    if (_selectedGroupId != null) {
      filteredMessages = _messages
          .where((msg) => msg.groupId == _selectedGroupId)
          .toList();
    } else {
      filteredMessages = _messages
          .where((msg) => 
              (msg.senderId == _currentUserId && msg.receiverId == _selectedUserId) ||
              (msg.senderId == _selectedUserId && msg.receiverId == _currentUserId))
          .toList();
    }

    // Sắp xếp tin nhắn theo thời gian, cũ nhất lên đầu
    filteredMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filteredMessages;
  }

  // Khởi tạo người dùng
  void initializeWithUser(AuthUser user) {
    _currentUserId = user.id;
    
    // Cập nhật hoặc thêm người dùng mới vào danh sách nếu chưa có
    if (!_users.any((u) => u.id == user.id)) {
      _users.add(User(
        id: user.id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
      ));
    }
    
    notifyListeners();
  }

  // Reset khi đăng xuất
  void reset() {
    _currentUserId = null;
    _selectedUserId = null;
    _selectedGroupId = null;
    notifyListeners();
  }

  // Chọn người dùng để chat
  void selectUser(String? userId) {
    _selectedUserId = userId;
    _selectedGroupId = null; // Reset selected group khi chọn user
    notifyListeners();
  }

  // Gửi tin nhắn cá nhân
  Future<void> sendMessage(String content, {MessageType type = MessageType.text}) async {
    if (_currentUserId == null || _selectedUserId == null) return;

    try {
      final message = Message(
        id: DateTime.now().toString(),
        content: content,
        senderId: _currentUserId!,
        receiverId: _selectedUserId!,
        timestamp: DateTime.now(),
        type: type,
      );
      
      _messages.add(message);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi gửi tin nhắn: $e');
    }
  }

  // Tạo nhóm mới
  Future<void> createGroup(String name, List<String> memberIds) async {
    if (_currentUserId == null) return;

    final group = Group(
      id: DateTime.now().toString(),
      name: name,
      adminId: _currentUserId!,
      memberIds: [...memberIds, _currentUserId!],
      createdAt: DateTime.now(),
    );

    _groups.add(group);
    notifyListeners();
  }

  // Thêm thành viên vào nhóm
  Future<void> addMembersToGroup(String groupId, List<String> memberIds) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    if (group.adminId != _currentUserId) return; // Chỉ admin mới có thể thêm thành viên

    final updatedGroup = Group(
      id: group.id,
      name: group.name,
      avatarUrl: group.avatarUrl,
      adminId: group.adminId,
      memberIds: [...group.memberIds, ...memberIds],
      createdAt: group.createdAt,
    );

    _groups[groupIndex] = updatedGroup;
    notifyListeners();
  }

  // Rời nhóm
  Future<void> leaveGroup(String groupId) async {
    if (_currentUserId == null) return;

    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    if (group.adminId == _currentUserId) {
      // Nếu là admin, xóa nhóm
      _groups.removeAt(groupIndex);
    } else {
      // Nếu là thành viên, rời nhóm
      final updatedGroup = Group(
        id: group.id,
        name: group.name,
        avatarUrl: group.avatarUrl,
        adminId: group.adminId,
        memberIds: group.memberIds.where((id) => id != _currentUserId).toList(),
        createdAt: group.createdAt,
      );
      _groups[groupIndex] = updatedGroup;
    }
    notifyListeners();
  }

  // Chọn nhóm để chat
  void selectGroup(String? groupId) {
    _selectedGroupId = groupId;
    _selectedUserId = null; // Reset selected user khi chọn nhóm
    notifyListeners();
  }

  // Gửi tin nhắn trong nhóm
  Future<void> sendGroupMessage(String content, {MessageType type = MessageType.text}) async {
    if (_currentUserId == null || _selectedGroupId == null) return;

    try {
      final message = Message(
        id: DateTime.now().toString(),
        content: content,
        senderId: _currentUserId!,
        receiverId: '',
        groupId: _selectedGroupId,
        timestamp: DateTime.now(),
        type: type,
      );
      
      _messages.add(message);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi gửi tin nhắn: $e');
    }
  }

  // Lấy danh sách bạn bè
  List<User> get friends {
    if (_currentUserId == null) return [];
    
    // Lấy các ID của những người đã kết bạn
    final friendIds = _friendships
        .where((f) => (f.senderId == _currentUserId || f.receiverId == _currentUserId) 
            && f.status == FriendshipStatus.accepted)
        .map((f) => f.senderId == _currentUserId ? f.receiverId : f.senderId)
        .toList();
    
    // Lấy thông tin người dùng từ danh sách ID
    return _users.where((user) => friendIds.contains(user.id)).toList();
  }

  // Lấy danh sách lời mời kết bạn
  List<User> get friendRequests {
    if (_currentUserId == null) return [];
    
    final requestIds = _friendships
        .where((f) => f.receiverId == _currentUserId 
            && f.status == FriendshipStatus.pending)
        .map((f) => f.senderId)
        .toList();
    
    return _users.where((user) => requestIds.contains(user.id)).toList();
  }

  // Kiểm tra trạng thái kết bạn
  FriendshipStatus? getFriendshipStatus(String userId) {
    if (_currentUserId == null) return null;
    
    final friendship = _friendships.firstWhere(
      (f) => (f.senderId == _currentUserId && f.receiverId == userId) ||
             (f.senderId == userId && f.receiverId == _currentUserId),
      orElse: () => Friendship(
        id: '',
        senderId: '',
        receiverId: '',
        status: FriendshipStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    
    return friendship.id.isEmpty ? null : friendship.status;
  }

  // Gửi lời mời kết bạn
  Future<void> sendFriendRequest(String userId) async {
    if (_currentUserId == null) return;

    if (getFriendshipStatus(userId) != null) return;

    final friendship = Friendship(
      id: DateTime.now().toString(),
      senderId: _currentUserId!,
      receiverId: userId,
      status: FriendshipStatus.pending,
      createdAt: DateTime.now(),
    );

    _friendships.add(friendship);
    notifyListeners();
  }

  // Chấp nhận lời mời kết bạn
  Future<void> acceptFriendRequest(String userId) async {
    if (_currentUserId == null) return;

    final friendshipIndex = _friendships.indexWhere(
      (f) => f.senderId == userId && 
            f.receiverId == _currentUserId &&
            f.status == FriendshipStatus.pending
    );

    if (friendshipIndex != -1) {
      _friendships[friendshipIndex] = Friendship(
        id: _friendships[friendshipIndex].id,
        senderId: _friendships[friendshipIndex].senderId,
        receiverId: _friendships[friendshipIndex].receiverId,
        status: FriendshipStatus.accepted,
        createdAt: _friendships[friendshipIndex].createdAt,
      );
      notifyListeners();
    }
  }

  // Từ chối lời mời kết bạn
  Future<void> declineFriendRequest(String userId) async {
    if (_currentUserId == null) return;

    final friendshipIndex = _friendships.indexWhere(
      (f) => f.senderId == userId && 
            f.receiverId == _currentUserId &&
            f.status == FriendshipStatus.pending
    );

    if (friendshipIndex != -1) {
      _friendships[friendshipIndex] = Friendship(
        id: _friendships[friendshipIndex].id,
        senderId: _friendships[friendshipIndex].senderId,
        receiverId: _friendships[friendshipIndex].receiverId,
        status: FriendshipStatus.declined,
        createdAt: _friendships[friendshipIndex].createdAt,
      );
      notifyListeners();
    }
  }

  // Hủy kết bạn
  Future<void> unfriend(String userId) async {
    if (_currentUserId == null) return;

    _friendships.removeWhere(
      (f) => ((f.senderId == _currentUserId && f.receiverId == userId) ||
              (f.senderId == userId && f.receiverId == _currentUserId)) &&
             f.status == FriendshipStatus.accepted
    );
    notifyListeners();
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Thêm phương thức xóa thành viên khỏi nhóm
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    if (group.adminId != _currentUserId) return;

    final updatedGroup = Group(
      id: group.id,
      name: group.name,
      avatarUrl: group.avatarUrl,
      adminId: group.adminId,
      memberIds: group.memberIds.where((id) => id != userId).toList(),
      createdAt: group.createdAt,
    );

    _groups[groupIndex] = updatedGroup;
    notifyListeners();
  }

  void updateUserProfile(String userId, {String? name, String? avatarUrl}) {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      _users[userIndex] = User(
        id: _users[userIndex].id,
        name: name ?? _users[userIndex].name,
        email: _users[userIndex].email,
        avatarUrl: avatarUrl ?? _users[userIndex].avatarUrl,
      );
      notifyListeners();
    }
  }

  bool isUserBlocked(String userId) => _blockedUsers.contains(userId);
  bool isUserMuted(String userId) => _mutedUsers.contains(userId);

  void toggleBlockUser(String userId) {
    if (_blockedUsers.contains(userId)) {
      _blockedUsers.remove(userId);
    } else {
      _blockedUsers.add(userId);
    }
    notifyListeners();
  }

  void toggleMuteUser(String userId) {
    if (_mutedUsers.contains(userId)) {
      _mutedUsers.remove(userId);
    } else {
      _mutedUsers.add(userId);
    }
    notifyListeners();
  }

  void clearChatHistory(String userId) {
    _messages.removeWhere((msg) => 
      (msg.senderId == _currentUserId && msg.receiverId == userId) ||
      (msg.senderId == userId && msg.receiverId == _currentUserId)
    );
    notifyListeners();
  }

  Future<void> reportUser(String userId, String reason) async {
    print('Đã báo cáo người dùng $userId với lý do: $reason');
  }

  bool isUserTyping(String userId) => _typingUsers.containsKey(userId);
  DateTime? getLastTypingTime(String userId) => _typingUsers[userId];
  String get searchQuery => _searchQuery;

  void updateUserOnlineStatus(String userId, {
    required bool isOnline,
    DateTime? lastSeen,
  }) {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(
        isOnline: isOnline,
        lastSeen: lastSeen ?? DateTime.now(),
      );
      notifyListeners();
    }
  }

  void setTypingStatus(String userId, bool isTyping) {
    if (isTyping) {
      _typingUsers[userId] = DateTime.now();
    } else {
      _typingUsers.remove(userId);
    }
    notifyListeners();
  }

  void markMessageAsRead(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(
        status: MessageStatus.read,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void markAllMessagesAsRead(String senderId) {
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].senderId == senderId && !_messages[i].isRead) {
        _messages[i] = _messages[i].copyWith(
          status: MessageStatus.read,
          isRead: true,
        );
      }
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Message> get filteredMessages {
    if (_searchQuery.isEmpty) return messages;
    return messages.where((msg) =>
      msg.content.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  int getUnreadCount(String senderId) {
    return _messages.where((msg) =>
      msg.senderId == senderId && !msg.isRead
    ).length;
  }
}