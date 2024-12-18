import '../services/api_service.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/group.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // User methods
  Future<List<User>> getUsers() async {
    return await _apiService.getUsers();
  }

  Future<void> updateUserProfile(String userId, {String? name, String? avatarUrl}) async {
    await _apiService.updateUserProfile(userId, name: name, avatarUrl: avatarUrl);
  }

  Future<void> updateUserStatus(String userId, {
    required bool isOnline,
    DateTime? lastSeen,
  }) async {
    await _apiService.updateUserStatus(
      userId,
      isOnline: isOnline,
      lastSeen: lastSeen,
    );
  }

  // Message methods
  Future<List<Message>> getMessages({String? userId, String? groupId}) async {
    return await _apiService.getMessages(userId: userId, groupId: groupId);
  }

  Future<Message> sendMessage(Message message) async {
    return await _apiService.sendMessage(message);
  }

  Future<void> markMessageAsRead(String messageId) async {
    await _apiService.markMessageAsRead(messageId);
  }

  // Group methods
  Future<List<Group>> getGroups() async {
    return await _apiService.getGroups();
  }

  Future<Group> createGroup(Group group) async {
    return await _apiService.createGroup(group);
  }

  Future<void> updateGroup(String groupId, {
    String? name,
    String? avatarUrl,
    List<String>? memberIds,
  }) async {
    await _apiService.updateGroup(
      groupId,
      name: name,
      avatarUrl: avatarUrl,
      memberIds: memberIds,
    );
  }

  Future<void> deleteGroup(String groupId) async {
    await _apiService.deleteGroup(groupId);
  }
} 