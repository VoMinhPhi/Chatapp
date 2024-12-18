import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/auth_user.dart';

class AuthProvider with ChangeNotifier {
  AuthUser? _currentUser;
  final Dio _dio = Dio();
  bool _isLoading = false;

  // Lưu trữ danh sách tài khoản đã đăng ký
  final List<Map<String, dynamic>> _registeredAccounts = [
    {
      'email': 'user1@example.com',
      'password': 'password',
      'name': 'Người dùng 1',
      'id': '1',
      'avatarUrl': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'email': 'user2@example.com',
      'password': 'password',
      'name': 'Người dùng 2',
      'id': '2',
      'avatarUrl': 'https://i.pravatar.cc/150?img=2',
    },
  ];

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));

      // Tìm tài khoản trong danh sách đã đăng ký
      final account = _registeredAccounts.firstWhere(
        (acc) => acc['email'] == email && acc['password'] == password,
        orElse: () => throw Exception('Email hoặc mật khẩu không đúng'),
      );

      // Kiểm tra và chuyển đổi kiểu dữ liệu
      final id = account['id']?.toString() ?? '';
      final accountEmail = account['email']?.toString() ?? '';
      final name = account['name']?.toString() ?? '';
      final avatarUrl = account['avatarUrl']?.toString();

      _currentUser = AuthUser(
        id: id,
        email: accountEmail,
        name: name,
        avatarUrl: avatarUrl,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));

      // Kiểm tra email đã tồn tại
      if (_registeredAccounts.any((acc) => acc['email'] == email)) {
        throw Exception('Email đã được sử dụng');
      }

      // Tạo ID mới
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Tạo tài khoản mới
      final newAccount = {
        'id': id,
        'email': email,
        'password': password,
        'name': name,
        'avatarUrl': 'https://i.pravatar.cc/150?img=${DateTime.now().second}',
      };

      // Thêm vào danh sách tài khoản
      _registeredAccounts.add(newAccount);

      // Tự động đăng nhập sau khi đăng ký
      _currentUser = AuthUser(
        id: id,
        email: email,
        name: name,
        avatarUrl: newAccount['avatarUrl']?.toString(),
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    if (_currentUser == null) return;

    // Cập nhật thông tin người dùng
    _currentUser = AuthUser(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );

    notifyListeners();
  }
} 