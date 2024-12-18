import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/group.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl = 'https://api.example.com'; // Thay đổi URL API của bạn

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  // Auth APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // User APIs
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((json) => User(
                id: json['id'],
                name: json['name'],
                email: json['email'],
                avatarUrl: json['avatarUrl'],
                isOnline: json['isOnline'] ?? false,
                lastSeen: json['lastSeen'] != null 
                    ? DateTime.parse(json['lastSeen']) 
                    : null,
              ))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateUserProfile(String userId, {String? name, String? avatarUrl}) async {
    try {
      await _dio.patch('/users/$userId', data: {
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateUserStatus(String userId, {
    required bool isOnline,
    DateTime? lastSeen,
  }) async {
    try {
      await _dio.patch('/users/$userId/status', data: {
        'isOnline': isOnline,
        if (lastSeen != null) 'lastSeen': lastSeen.toIso8601String(),
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Message APIs
  Future<List<Message>> getMessages({String? userId, String? groupId}) async {
    try {
      final response = await _dio.get(
        '/messages',
        queryParameters: {
          if (userId != null) 'userId': userId,
          if (groupId != null) 'groupId': groupId,
        },
      );
      return (response.data as List)
          .map((json) => Message(
                id: json['id'],
                content: json['content'],
                senderId: json['senderId'],
                receiverId: json['receiverId'],
                groupId: json['groupId'],
                timestamp: DateTime.parse(json['timestamp']),
                type: MessageType.values[json['type']],
                status: MessageStatus.values[json['status']],
                isRead: json['isRead'],
              ))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Message> sendMessage(Message message) async {
    try {
      final response = await _dio.post('/messages', data: {
        'content': message.content,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'groupId': message.groupId,
        'type': message.type.index,
      });
      return Message(
        id: response.data['id'],
        content: response.data['content'],
        senderId: response.data['senderId'],
        receiverId: response.data['receiverId'],
        groupId: response.data['groupId'],
        timestamp: DateTime.parse(response.data['timestamp']),
        type: MessageType.values[response.data['type']],
        status: MessageStatus.values[response.data['status']],
        isRead: response.data['isRead'],
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _dio.patch('/messages/$messageId/read');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Group APIs
  Future<List<Group>> getGroups() async {
    try {
      final response = await _dio.get('/groups');
      return (response.data as List)
          .map((json) => Group(
                id: json['id'],
                name: json['name'],
                avatarUrl: json['avatarUrl'],
                adminId: json['adminId'],
                memberIds: List<String>.from(json['memberIds']),
                createdAt: DateTime.parse(json['createdAt']),
              ))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Group> createGroup(Group group) async {
    try {
      final response = await _dio.post('/groups', data: {
        'name': group.name,
        'avatarUrl': group.avatarUrl,
        'adminId': group.adminId,
        'memberIds': group.memberIds,
      });
      return Group(
        id: response.data['id'],
        name: response.data['name'],
        avatarUrl: response.data['avatarUrl'],
        adminId: response.data['adminId'],
        memberIds: List<String>.from(response.data['memberIds']),
        createdAt: DateTime.parse(response.data['createdAt']),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateGroup(String groupId, {
    String? name,
    String? avatarUrl,
    List<String>? memberIds,
  }) async {
    try {
      await _dio.patch('/groups/$groupId', data: {
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (memberIds != null) 'memberIds': memberIds,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _dio.delete('/groups/$groupId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Kết nối tới server thất bại');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['message'] ?? 'Lỗi không xác định';
          return Exception('$statusCode: $message');
        default:
          return Exception('Đã có lỗi xảy ra');
      }
    }
    return Exception('Đã có lỗi xảy ra');
  }
} 