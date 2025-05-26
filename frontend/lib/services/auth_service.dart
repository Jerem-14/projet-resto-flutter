import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _jwtToken;
  bool _isLoading = false;



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
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        final data = result['data'];
        _jwtToken = data['token'];
        
        // Adapter les données de l'API au format attendu par le modèle User
        final userData = {
          'id': data['user']['id'],
          'email': data['user']['email'],
          'first_name': data['user']['first_name'],
          'last_name': data['user']['last_name'],
          'phone': data['user']['phone'],
          'role': data['user']['role'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        _currentUser = User.fromJson(userData);

        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': 'Connexion réussie',
          'user': _currentUser,
          'token': _jwtToken,
        };
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (result['success']) {
        final data = result['data'];
        _jwtToken = data['token'];
        
        // Adapter les données de l'API au format attendu par le modèle User
        final userData = {
          'id': data['user']['id'],
          'email': data['user']['email'],
          'first_name': data['user']['first_name'],
          'last_name': data['user']['last_name'],
          'phone': data['user']['phone'],
          'role': data['user']['role'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        _currentUser = User.fromJson(userData);

        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': 'Inscription réussie',
          'user': _currentUser,
          'token': _jwtToken,
        };
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
      };
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    _jwtToken = null;
    notifyListeners();
  }

  // Check if token is valid
  bool isTokenValid() {
    return _jwtToken != null && _jwtToken!.isNotEmpty;
  }

  // Verify token with API
  Future<bool> verifyTokenWithAPI() async {
    if (_jwtToken == null) return false;
    
    try {
      final result = await ApiService.verifyToken(_jwtToken!);
      return result['success'];
    } catch (e) {
      return false;
    }
  }
} 