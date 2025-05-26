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

  // Get availability data for reservations
  static Future<Map<String, dynamic>> getAvailability() async {
    try {
      developer.log('📅 Récupération des disponibilités');
      developer.log('📡 URL: $baseUrl/availability');

      final response = await http.get(
        Uri.parse('$baseUrl/availability'),
        headers: _headers,
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        developer.log(
          '✅ Disponibilités récupérées avec succès (${data.length} jours)',
        );
        return {'success': true, 'data': data};
      } else {
        developer.log('❌ Erreur lors de la récupération des disponibilités');
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des disponibilités',
        };
      }
    } catch (e) {
      developer.log(
        '💥 Exception lors de la récupération des disponibilités: $e',
      );
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Create a new reservation
  static Future<Map<String, dynamic>> createReservation({
    required int timeslotId,
    required String reservationDate,
    required int numberOfGuests,
    required String token,
  }) async {
    try {
      developer.log('🍽️ Création d\'une réservation');
      developer.log('📡 URL: $baseUrl/reservations');
      developer.log(
        '📊 Data: timeslot_id=$timeslotId, date=$reservationDate, guests=$numberOfGuests',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: _headersWithAuth(token),
        body: jsonEncode({
          'timeslot_id': timeslotId,
          'reservation_date': reservationDate,
          'number_of_guests': numberOfGuests,
        }),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        developer.log('✅ Réservation créée avec succès');
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        developer.log(
          '❌ Erreur lors de la création de la réservation: ${errorData['error']}',
        );
        return {
          'success': false,
          'message':
              errorData['error'] ??
              'Erreur lors de la création de la réservation',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la création de la réservation: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Get user's reservations
  static Future<Map<String, dynamic>> getUserReservations(String token) async {
    try {
      developer.log('📋 Récupération des réservations utilisateur');
      developer.log('📡 URL: $baseUrl/reservations/my');

      final response = await http.get(
        Uri.parse('$baseUrl/reservations/my'),
        headers: _headersWithAuth(token),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        developer.log(
          '✅ Réservations récupérées avec succès (${data.length} réservations)',
        );
        return {'success': true, 'data': data};
      } else {
        developer.log('❌ Erreur lors de la récupération des réservations');
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des réservations',
        };
      }
    } catch (e) {
      developer.log(
        '💥 Exception lors de la récupération des réservations: $e',
      );
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
      developer.log('⏰ [ApiService] Début récupération des créneaux horaires');

      // Construction de l'URL
      final baseUrlWithoutApi = baseUrl.replaceAll('/api', '');
      final fullUrl = '$baseUrl/admin/timeslots';
      developer.log('📡 [ApiService] URL construite: $fullUrl');
      developer.log('📡 [ApiService] Base URL original: $baseUrl');
      developer.log('📡 [ApiService] Base URL sans /api: $baseUrlWithoutApi');

      // Préparation des headers
      final headers = _headersWithAuth(token);
      developer.log('🔐 [ApiService] Headers préparés: $headers');
      developer.log(
        '🔐 [ApiService] Token utilisé: ${token.substring(0, 20)}...',
      );

      developer.log('📤 [ApiService] Envoi de la requête GET...');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/timeslots'),
        headers: _headersWithAuth(token),
      );

      developer.log('📥 [ApiService] Réponse reçue');
      developer.log('📥 [ApiService] Status Code: ${response.statusCode}');
      developer.log('📥 [ApiService] Headers de réponse: ${response.headers}');
      developer.log('📥 [ApiService] Body brut: ${response.body}');
      developer.log(
        '📥 [ApiService] Content-Type: ${response.headers['content-type']}',
      );

      // Vérification du content-type
      final contentType = response.headers['content-type'];
      if (contentType != null && !contentType.contains('application/json')) {
        developer.log('⚠️ [ApiService] Content-Type inattendu: $contentType');
      }

      if (response.statusCode == 200) {
        developer.log(
          '✅ [ApiService] Status 200 - Tentative de parsing JSON...',
        );

        try {
          final dynamic parsedData = jsonDecode(response.body);
          developer.log('✅ [ApiService] JSON parsé avec succès');
          developer.log(
            '📊 [ApiService] Type de données: ${parsedData.runtimeType}',
          );
          developer.log('📊 [ApiService] Contenu: $parsedData');

          // Vérification si c'est une liste
          if (parsedData is List) {
            developer.log(
              '📋 [ApiService] Données sous forme de liste (${parsedData.length} éléments)',
            );
            for (int i = 0; i < parsedData.length && i < 3; i++) {
              developer.log('📄 [ApiService] Élément $i: ${parsedData[i]}');
            }
          } else {
            developer.log(
              '📄 [ApiService] Données sous forme d\'objet: $parsedData',
            );
          }

          return {'success': true, 'data': parsedData};
        } catch (jsonError, stackTrace) {
          developer.log('💥 [ApiService] Erreur parsing JSON: $jsonError');
          developer.log('📚 [ApiService] Stack trace JSON: $stackTrace');
          developer.log(
            '📄 [ApiService] Body qui a causé l\'erreur: ${response.body}',
          );
          return {
            'success': false,
            'message': 'Erreur de format de réponse: $jsonError',
          };
        }
      } else {
        developer.log('❌ [ApiService] Erreur HTTP ${response.statusCode}');

        try {
          final errorData = jsonDecode(response.body);
          developer.log('📄 [ApiService] Message d\'erreur parsé: $errorData');
          return {
            'success': false,
            'message':
                errorData['message'] ?? 'Erreur HTTP ${response.statusCode}',
          };
        } catch (e) {
          developer.log('💥 [ApiService] Impossible de parser l\'erreur: $e');
          developer.log(
            '📄 [ApiService] Body d\'erreur brut: ${response.body}',
          );
          return {
            'success': false,
            'message': 'Erreur HTTP ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e, stackTrace) {
      developer.log('💥 [ApiService] Exception dans getTimeslots: $e');
      developer.log('📚 [ApiService] Stack trace complet: $stackTrace');
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
      developer.log('📡 URL: $baseUrl/../admin/timeslots');

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
      developer.log('📡 URL: $baseUrl/../admin/timeslots/$timeslotId');

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
      developer.log('📡 URL: $baseUrl/../admin/timeslots/$timeslotId');

      final response = await http.delete(
        Uri.parse(
          '${baseUrl.replaceAll('/api', '')}/admin/timeslots/$timeslotId',
        ),
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
