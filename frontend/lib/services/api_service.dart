import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class ApiService {
  // Choisissez l'URL appropriée selon votre environnement :
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:3000/api'; // iOS Simulator
  // static const String baseUrl = 'http://localhost:3000/api'; // Web/Desktop
  // static const String baseUrl = 'http://192.168.1.XXX:3000/api'; // Appareil physique (remplacez XXX)
  
  // Headers par défaut
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Headers avec token d'authentification
  static Map<String, String> _headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Register user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      developer.log('🚀 Tentative d\'inscription pour: $email');
      developer.log('📡 URL: $baseUrl/auth/register');
      
      final requestBody = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      };
      
      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('✅ Inscription réussie');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur d\'inscription: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de l\'inscription: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      developer.log('🔐 Tentative de connexion pour: $email');
      developer.log('📡 URL: $baseUrl/auth/login');
      
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Connexion réussie');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur de connexion: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la connexion: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Verify token (pour vérifier si le token est encore valide)
  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Token invalide',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
      };
    }
  }
} 