import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'api_service.dart';

class MenuApiService {
  // Headers par défaut
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Headers avec token d'authentification
  static Map<String, String> _headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
// ==========================================
  // MÉTHODES PUBLIQUES (sans authentification)
  // ==========================================

  /// Récupérer toutes les catégories actives (pour le menu public)
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      developer.log('🔍 Récupération des catégories publiques');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu/categories');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/menu/categories'),
        headers: _headers,
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Catégories publiques récupérées avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la récupération des catégories: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la récupération des catégories',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la récupération des catégories: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// Récupérer TOUTES les catégories (actives et inactives) pour l'admin
  static Future<Map<String, dynamic>> getAllCategories(String token) async {
    try {
      developer.log('🔍 Récupération de toutes les catégories (admin)');
  
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/menu/categories'),
        headers: _headersWithAuth(token),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Toutes les catégories récupérées avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la récupération des catégories: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la récupération des catégories',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la récupération des catégories: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// Récupérer le menu complet avec les items disponibles
  static Future<Map<String, dynamic>> getMenu() async {
    try {
      developer.log('🔍 Récupération du menu complet');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/menu'),
        headers: _headers,
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Menu récupéré avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la récupération du menu: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la récupération du menu',
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

  // ==========================================
  // MÉTHODES ADMIN - CATÉGORIES
  // ==========================================

  /// Créer une nouvelle catégorie (Admin uniquement)
  static Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    required String token, // Passer le token en paramètre
  }) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Token d\'authentification manquant',
        };
      }

      developer.log('🚀 Création d\'une nouvelle catégorie: $name');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu/admin/categories');

      final requestBody = {
        'name': name,
        if (description != null) 'description': description,
      };

      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/menu/admin/categories'),
        headers: _headersWithAuth(token),
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        developer.log('✅ Catégorie créée avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la création de la catégorie: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la création de la catégorie',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la création de la catégorie: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// Modifier une catégorie existante (Admin uniquement)
  static Future<Map<String, dynamic>> updateCategory({
    required int categoryId,
    String? name,
    String? description,
    bool? isActive,
    required String token, // Passer le token en paramètre
  }) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Token d\'authentification manquant',
        };
      }

      developer.log('🔄 Modification de la catégorie ID: $categoryId');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu/admin/categories/$categoryId');

      final requestBody = <String, dynamic>{};
      if (name != null) requestBody['name'] = name;
      if (description != null) requestBody['description'] = description;
      if (isActive != null) requestBody['is_active'] = isActive;

      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/menu/admin/categories/$categoryId'),
        headers: _headersWithAuth(token),
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Catégorie mise à jour avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la mise à jour de la catégorie: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la mise à jour de la catégorie',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la mise à jour de la catégorie: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// Supprimer une catégorie (Admin uniquement)
  static Future<Map<String, dynamic>> deleteCategory(int categoryId, String token) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Token d\'authentification manquant',
        };
      }

      developer.log('🗑️ Suppression de la catégorie ID: $categoryId');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu/admin/categories/$categoryId');

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/menu/admin/categories/$categoryId'),
        headers: _headersWithAuth(token),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Catégorie supprimée avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la suppression de la catégorie: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la suppression de la catégorie',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la suppression de la catégorie: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // ==========================================
  // MÉTHODES ADMIN - ITEMS MENU
  // ==========================================

  /// Créer un nouveau plat (Admin uniquement)
  static Future<Map<String, dynamic>> createMenuItem({
    required int categoryId,
    required String name,
    String? description,
    required double price,
    bool isAvailable = true,
    required String token, // Passer le token en paramètre
  }) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Token d\'authentification manquant',
        };
      }

      developer.log('🚀 Création d\'un nouveau plat: $name');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu/admin/items');

      final requestBody = {
        'category_id': categoryId,
        'name': name,
        'price': price,
        'is_available': isAvailable,
        if (description != null) 'description': description,
      };

      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/menu/admin/items'),
        headers: _headersWithAuth(token),
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        developer.log('✅ Plat créé avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la création du plat: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la création du plat',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la création du plat: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// Modifier un plat existant (Admin uniquement)
  static Future<Map<String, dynamic>> updateMenuItem({
    required int itemId,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
    required String token, // Passer le token en paramètre
  }) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Token d\'authentification manquant',
        };
      }

      developer.log('🔄 Modification du plat ID: $itemId');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu/admin/items/$itemId');

      final requestBody = <String, dynamic>{};
      if (categoryId != null) requestBody['category_id'] = categoryId;
      if (name != null) requestBody['name'] = name;
      if (description != null) requestBody['description'] = description;
      if (price != null) requestBody['price'] = price;
      if (isAvailable != null) requestBody['is_available'] = isAvailable;

      developer.log('📤 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/menu/admin/items/$itemId'),
        headers: _headersWithAuth(token),
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Plat mis à jour avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la mise à jour du plat: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la mise à jour du plat',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la mise à jour du plat: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  /// Supprimer un plat (Admin uniquement)
  static Future<Map<String, dynamic>> deleteMenuItem(int itemId, String token) async {
    try {
      if (token.isEmpty) {
        return {
          'success': false,
          'message': 'Token d\'authentification manquant',
        };
      }

      developer.log('🗑️ Suppression du plat ID: $itemId');
      developer.log('📡 URL: ${ApiService.baseUrl}/menu/admin/items/$itemId');

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/menu/admin/items/$itemId'),
        headers: _headersWithAuth(token),
      );

      developer.log('📥 Status Code: ${response.statusCode}');
      developer.log('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ Plat supprimé avec succès');
        return {
          'success': true,
          'data': data,
        };
      } else {
        developer.log('❌ Erreur lors de la suppression du plat: ${data['error']}');
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la suppression du plat',
        };
      }
    } catch (e) {
      developer.log('💥 Exception lors de la suppression du plat: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }
}