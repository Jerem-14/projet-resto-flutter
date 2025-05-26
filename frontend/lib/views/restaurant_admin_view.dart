import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class RestaurantAdminView extends StatefulWidget {
  const RestaurantAdminView({super.key});

  @override
  State<RestaurantAdminView> createState() => _RestaurantAdminViewState();
}

class _RestaurantAdminViewState extends State<RestaurantAdminView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  // ID hardcodé du restaurant
  final int restaurantId = 1;

  // Headers avec token d'authentification
  Map<String, String> _headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/restaurants/$restaurantId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _nameController.text = data['restaurant_name'] ?? '';
        _capacityController.text = data['total_capacity']?.toString() ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _descriptionController.text = data['description'] ?? '';
      } else if (response.statusCode == 404) {
        // Restaurant n'existe pas, on garde les champs vides
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restaurant non trouvé, vous pouvez créer les données'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoadingData = false;
    });
  }

  Future<void> _saveRestaurant(String token) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requestBody = {
        'restaurant_name': _nameController.text,
        'total_capacity': int.parse(_capacityController.text),
        'phone': _phoneController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
      };

      // Essayer d'abord de modifier
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/restaurants/$restaurantId'),
        headers: _headersWithAuth(token),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restaurant modifié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (response.statusCode == 404) {
        // Si le restaurant n'existe pas, le créer
        final createResponse = await http.post(
          Uri.parse('${ApiService.baseUrl}/restaurants'),
          headers: _headersWithAuth(token),
          body: json.encode(requestBody),
        );

        if (createResponse.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Restaurant créé avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Erreur lors de la création');
        }
      } else {
        throw Exception('Erreur lors de la modification');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Vérifier l'accès admin
        if (!authService.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Accès refusé',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Accès refusé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Vous devez être administrateur pour accéder à cette page',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Gestion Restaurant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations du Restaurant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Nom du restaurant
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du restaurant',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.restaurant),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom du restaurant';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Capacité
                        TextFormField(
                          controller: _capacityController,
                          decoration: const InputDecoration(
                            labelText: 'Capacité totale',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.people),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la capacité';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Veuillez entrer un nombre valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Téléphone
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le numéro de téléphone';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Adresse
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer l\'adresse';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        
                        // Bouton sauvegarder
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              final token = authService.jwtToken;
                              if (token == null || token.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Token d\'authentification manquant'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              await _saveRestaurant(token);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 