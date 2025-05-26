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
        return {'success': true, 'data': data};
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

      final requestBody = {'email': email, 'password': password};

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
        return {'success': true, 'data': data};
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
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Token invalide'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  // Get menu items
  static Future<Map<String, dynamic>> getMenu() async {
    try {
      developer.log('🍽️ Récupération du menu');
      developer.log('📡 URL: $baseUrl/menu');

      final response = await http.get(
        Uri.parse('$baseUrl/menu'),
        headers: _headers,
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        developer.log('✅ Menu récupéré avec succès (${data.length} éléments)');
        return {'success': true, 'data': data};
      } else {
        developer.log('❌ Erreur lors de la récupération du menu');
        return {
          'success': false,
          'message': 'Erreur lors de la récupération du menu',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la récupération du menu: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // ===== TIMESLOTS MANAGEMENT =====

  // Get all timeslots
  static Future<Map<String, dynamic>> getTimeslots(String token) async {
    try {
      developer.log('⏰ Récupération des créneaux horaires');
      developer.log('📡 URL: $baseUrl/admin/timeslots');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/timeslots'),
        headers: _headers,
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        developer.log(
          '✅ Créneaux récupérés avec succès (${data.length} éléments)',
        );
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        developer.log(
          '❌ Erreur lors de la récupération des créneaux: ${errorData['message']}',
        );
        return {
          'success': false,
          'message':
              errorData['message'] ??
              'Erreur lors de la récupération des créneaux',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la récupération des créneaux: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Create new timeslot
  static Future<Map<String, dynamic>> createTimeslot({
    required String token,
    required String startTime,
    bool isActive = true,
  }) async {
    try {
      developer.log('🆕 Création d\'un nouveau créneau: $startTime');
      developer.log('📡 URL: $baseUrl/admin/timeslots');

      final requestBody = {
        'start_time': '$startTime:00', // Ajouter les secondes
        'is_active': isActive,
      };

      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/timeslots'),
        headers: _headersWithAuth(token),
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        developer.log('✅ Créneau créé avec succès');
        return {'success': true, 'data': data};
      } else {
        developer.log(
          '❌ Erreur lors de la création du créneau: ${data['message']}',
        );
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la création du créneau',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la création du créneau: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Update timeslot
  static Future<Map<String, dynamic>> updateTimeslot({
    required String token,
    required int timeslotId,
    String? startTime,
    bool? isActive,
  }) async {
    try {
      developer.log('✏️ Mise à jour du créneau $timeslotId');
      developer.log('📡 URL: $baseUrl/admin/timeslots/$timeslotId');

      final requestBody = <String, dynamic>{};
      if (startTime != null) requestBody['start_time'] = '$startTime:00';
      if (isActive != null) requestBody['is_active'] = isActive;

      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.patch(
        Uri.parse('$baseUrl/admin/timeslots/$timeslotId'),
        headers: _headersWithAuth(token),
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Créneau mis à jour avec succès');
        return {'success': true, 'data': data};
      } else {
        developer.log(
          '❌ Erreur lors de la mise à jour du créneau: ${data['message']}',
        );
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la mise à jour du créneau',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la mise à jour du créneau: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Delete timeslot
  static Future<Map<String, dynamic>> deleteTimeslot({
    required String token,
    required int timeslotId,
  }) async {
    try {
      developer.log('🗑️ Suppression du créneau $timeslotId');
      developer.log('📡 URL: $baseUrl/admin/timeslots/$timeslotId');

      final response = await http.delete(
        Uri.parse('$baseUrl./admin/timeslots/$timeslotId'),
        headers: _headersWithAuth(token),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        developer.log('✅ Créneau supprimé avec succès');
        return {'success': true, 'message': 'Créneau supprimé avec succès'};
      } else {
        final data = jsonDecode(response.body);
        developer.log(
          '❌ Erreur lors de la suppression du créneau: ${data['message']}',
        );
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la suppression du créneau',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la suppression du créneau: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }
}
