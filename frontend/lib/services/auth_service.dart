import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _jwtToken;
  bool _isLoading = false;

  // Dummy users data
  final List<Map<String, dynamic>> _dummyUsers = [
    {
      'id': 1,
      'email': 'user@example.com',
      'password': 'password123',
      'first_name': 'Jean',
      'last_name': 'Dupont',
      'role': 'user',
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
    {
      'id': 2,
      'email': 'admin@example.com',
      'password': 'admin123',
      'first_name': 'Marie',
      'last_name': 'Martin',
      'role': 'admin',
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
  ];

  // Getters
  User? get currentUser => _currentUser;
  String? get jwtToken => _jwtToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null && _jwtToken != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Find user in dummy data
      final userData = _dummyUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (userData.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      }

      // Create user and generate dummy JWT
      _currentUser = User.fromJson(userData);
      _jwtToken = _generateDummyJWT(userData['id'] as int, userData['role'] as String);

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'message': 'Connexion réussie',
        'user': _currentUser,
        'token': _jwtToken,
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if email already exists
      final existingUser = _dummyUsers.any((user) => user['email'] == email);
      if (existingUser) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'Cet email est déjà utilisé',
        };
      }

      // Create new user data
      final newUserData = {
        'id': _dummyUsers.length + 1,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': 'user', // Default role
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add to dummy users (in real app, this would be sent to API)
      _dummyUsers.add(newUserData);

      // Create user and generate dummy JWT
      _currentUser = User.fromJson(newUserData);
      _jwtToken = _generateDummyJWT(newUserData['id'] as int, newUserData['role'] as String);

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'message': 'Inscription réussie',
        'user': _currentUser,
        'token': _jwtToken,
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Erreur lors de l\'inscription',
      };
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    _jwtToken = null;
    notifyListeners();
  }

  // Generate dummy JWT token
  String _generateDummyJWT(int userId, String role) {
    // In a real app, this would be returned by the API
    final header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
    final payload = 'eyJzdWIiOiIkdXNlcklkIiwicm9sZSI6IiRyb2xlIiwiaWF0IjoxNjE2MjM5MDIyfQ';
    final signature = 'dummy_signature_${userId}_$role';
    return '$header.$payload.$signature';
  }

  // Check if token is valid (dummy implementation)
  bool isTokenValid() {
    return _jwtToken != null && _jwtToken!.isNotEmpty;
  }
} 