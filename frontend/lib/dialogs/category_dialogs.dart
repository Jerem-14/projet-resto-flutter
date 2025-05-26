import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_api_service.dart';
import '../services/auth_service.dart';

class CategoryDialogs {
  /// Dialog pour ajouter une nouvelle catégorie
  static void showAddCategoryDialog(
    BuildContext context, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Consumer<AuthService>(
        builder: (context, authService, child) => AlertDialog(
          title: const Text(
            'Ajouter une catégorie',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              const Text(
                '* Champs obligatoires',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                // Validation
                if (name.isEmpty) {
                  onError('Le nom de la catégorie est requis');
                  return;
                }

                if (name.length > 100) {
                  onError('Le nom de la catégorie ne peut pas dépasser 100 caractères');
                  return;
                }

                // Vérifier le token
                final token = authService.jwtToken;
                if (token == null || token.isEmpty) {
                  onError('Token d\'authentification manquant');
                  return;
                }

                Navigator.of(context).pop();

                // Appel API
                final result = await MenuApiService.createCategory(
                  name: name,
                  description: description.isEmpty ? null : description,
                  token: token,
                );

                if (result['success']) {
                  onSuccess();
                } else {
                  onError(result['message']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog pour modifier une catégorie existante
  static void showEditCategoryDialog(
    BuildContext context,
    Map<String, dynamic> category, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    final nameController = TextEditingController(text: category['name'] ?? '');
    final descriptionController = TextEditingController(text: category['description'] ?? '');
    bool isActive = category['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => Consumer<AuthService>(
        builder: (context, authService, child) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text(
              'Modifier la catégorie',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la catégorie *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.toggle_on, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Statut:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '* Champs obligatoires',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();

                  // Validation
                  if (name.isEmpty) {
                    onError('Le nom de la catégorie ne peut pas être vide');
                    return;
                  }

                  if (name.length > 100) {
                    onError('Le nom de la catégorie ne peut pas dépasser 100 caractères');
                    return;
                  }

                  // Vérifier le token
                  final token = authService.jwtToken;
                  if (token == null || token.isEmpty) {
                    onError('Token d\'authentification manquant');
                    return;
                  }

                  Navigator.of(context).pop();

                  // Appel API
                  final result = await MenuApiService.updateCategory(
                    categoryId: category['id'],
                    name: name,
                    description: description.isEmpty ? null : description,
                    isActive: isActive,
                    token: token,
                  );

                  if (result['success']) {
                    onSuccess();
                  } else {
                    onError(result['message']);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dialog pour confirmer la suppression d'une catégorie
  static void showDeleteCategoryDialog(
    BuildContext context,
    Map<String, dynamic> category, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AuthService>(
        builder: (context, authService, child) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Supprimer la catégorie',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Êtes-vous sûr de vouloir supprimer la catégorie ?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nom: ${category['name'] ?? 'Sans nom'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (category['description'] != null && category['description'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Description: ${category['description']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Statut: ${category['is_active'] == true ? 'Active' : 'Inactive'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: category['is_active'] == true ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cette action est irréversible. Assurez-vous qu\'aucun plat n\'est associé à cette catégorie.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Vérifier le token
                final token = authService.jwtToken;
                if (token == null || token.isEmpty) {
                  onError('Token d\'authentification manquant');
                  return;
                }

                Navigator.of(context).pop();

                // Appel API
                final result = await MenuApiService.deleteCategory(category['id'], token);

                if (result['success']) {
                  onSuccess();
                } else {
                  onError(result['message']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }
}