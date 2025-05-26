import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/menu_api_service.dart';
import '../services/auth_service.dart';

class MenuItemDialogs {
  /// Dialog pour ajouter un nouveau plat
  static void showAddMenuItemDialog(
    BuildContext context,
    List<Map<String, dynamic>> categories, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    int? selectedCategoryId;
    bool isAvailable = true;

    // Filtrer les catégories actives
    final activeCategories = categories.where((cat) => cat['is_active'] == true).toList();

    if (activeCategories.isEmpty) {
      onError('Aucune catégorie active disponible. Créez d\'abord une catégorie.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Consumer<AuthService>(
        builder: (context, authService, child) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text(
              'Ajouter un plat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du plat *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: activeCategories
                        .map((cat) => DropdownMenuItem<int>(
                              value: cat['id'],
                              child: Text(cat['name'] ?? 'Sans nom'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner une catégorie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix (€) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.euro),
                      suffixText: '€',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
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
                        const Icon(Icons.visibility, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Disponibilité:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          isAvailable ? 'Disponible' : 'Indisponible',
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
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
                  final priceText = priceController.text.trim();

                  // Validation
                  if (name.isEmpty || selectedCategoryId == null || priceText.isEmpty) {
                    onError('Tous les champs marqués * sont requis');
                    return;
                  }

                  if (name.length > 150) {
                    onError('Le nom du plat ne peut pas dépasser 150 caractères');
                    return;
                  }

                  final price = double.tryParse(priceText);
                  if (price == null || price < 0) {
                    onError('Le prix doit être un nombre positif');
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
                  final result = await MenuApiService.createMenuItem(
                    categoryId: selectedCategoryId!,
                    name: name,
                    description: description.isEmpty ? null : description,
                    price: price,
                    isAvailable: isAvailable,
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
      ),
    );
  }

  /// Dialog pour modifier un plat existant
  static void showEditMenuItemDialog(
    BuildContext context,
    Map<String, dynamic> item,
    List<Map<String, dynamic>> categories, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    final nameController = TextEditingController(text: item['name'] ?? '');
    final descriptionController = TextEditingController(text: item['description'] ?? '');
    final priceController = TextEditingController(text: item['price']?.toString() ?? '');
    int? selectedCategoryId = item['category_id'];
    bool isAvailable = item['is_available'] ?? true;

    // Filtrer les catégories actives
    final activeCategories = categories.where((cat) => cat['is_active'] == true).toList();

    if (activeCategories.isEmpty) {
      onError('Aucune catégorie active disponible. Créez d\'abord une catégorie.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Consumer<AuthService>(
        builder: (context, authService, child) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text(
              'Modifier le plat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du plat *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: activeCategories
                        .map((cat) => DropdownMenuItem<int>(
                              value: cat['id'],
                              child: Text(cat['name'] ?? 'Sans nom'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix (€) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.euro),
                      suffixText: '€',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
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
                        const Icon(Icons.visibility, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Disponibilité:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          isAvailable ? 'Disponible' : 'Indisponible',
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
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
                  final priceText = priceController.text.trim();

                  // Validation
                  if (name.isEmpty || selectedCategoryId == null || priceText.isEmpty) {
                    onError('Tous les champs marqués * sont requis');
                    return;
                  }

                  if (name.length > 150) {
                    onError('Le nom du plat ne peut pas dépasser 150 caractères');
                    return;
                  }

                  final price = double.tryParse(priceText);
                  if (price == null || price < 0) {
                    onError('Le prix doit être un nombre positif');
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
                  final result = await MenuApiService.updateMenuItem(
                    itemId: item['id'],
                    categoryId: selectedCategoryId!,
                    name: name,
                    description: description.isEmpty ? null : description,
                    price: price,
                    isAvailable: isAvailable,
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

  /// Dialog pour confirmer la suppression d'un plat
  static void showDeleteMenuItemDialog(
    BuildContext context,
    Map<String, dynamic> item, {
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
                'Supprimer le plat',
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
                'Êtes-vous sûr de vouloir supprimer ce plat ?',
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
                      'Nom: ${item['name'] ?? 'Sans nom'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Catégorie: ${item['category'] ?? 'Non définie'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Prix: ${item['price']?.toStringAsFixed(2) ?? '0.00'} €',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (item['description'] != null && item['description'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Description: ${item['description']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Statut: ${item['is_available'] == true ? 'Disponible' : 'Indisponible'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: item['is_available'] == true ? Colors.green : Colors.red,
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
                        'Cette action est irréversible.',
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
                final result = await MenuApiService.deleteMenuItem(item['id'], token);

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