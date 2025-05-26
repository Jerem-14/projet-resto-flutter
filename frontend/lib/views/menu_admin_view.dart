import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/menu_api_service.dart';
import '../dialogs/category_dialogs.dart';
import '../dialogs/menu_item_dialogs.dart';

class MenuAdminView extends StatefulWidget {
  const MenuAdminView({super.key});

  @override
  State<MenuAdminView> createState() => _MenuAdminViewState();
}

class _MenuAdminViewState extends State<MenuAdminView> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadCategories(),
        _loadMenuItems(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _loadCategories() async {
    try {
      // Utiliser getAllCategories pour récupérer toutes les catégories (actives et inactives)
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.jwtToken;
      
      if (token == null) {
        _showErrorSnackBar('Token d\'authentification manquant');
        return;
      }

      final result = await MenuApiService.getAllCategories(token);
      if (result['success']) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(result['data']);
        });
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement des catégories: $e');
    }
  }

    // Fonction helper pour vérifier le statut actif
  bool _isActive(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // Fonction helper pour vérifier la disponibilité
  bool _isAvailable(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Future<void> _loadMenuItems() async {
    try {
      final result = await MenuApiService.getMenu();
      if (result['success']) {
        setState(() {
          _menuItems = List<Map<String, dynamic>>.from(result['data']);
        });
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement des plats: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
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
              iconTheme: const IconThemeData(color: Colors.white),
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
              'Gestion du Menu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.orange,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(
                  icon: Icon(Icons.category),
                  text: 'Catégories',
                ),
                Tab(
                  icon: Icon(Icons.restaurant_menu),
                  text: 'Plats',
                ),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoriesTab(),
                    _buildMenuItemsTab(),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_currentTabIndex == 0) {
                _showAddCategoryDialog();
              } else {
                _showAddMenuItemDialog();
              }
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        // Stats header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange, Colors.orangeAccent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Total', _categories.length.toString(), Colors.white),
              _buildStatCard(
                'Actives',
                _categories.where((cat) => cat['is_active'] == true).length.toString(),
                Colors.green,
              ),
              _buildStatCard(
                'Inactives',
                _categories.where((cat) => cat['is_active'] == false).length.toString(),
                Colors.red,
              ),
            ],
          ),
        ),

        // Categories list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemsTab() {
    return Column(
      children: [
        // Stats header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange, Colors.orangeAccent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Total', _menuItems.length.toString(), Colors.white),
              _buildStatCard(
                'Disponibles',
                _menuItems.where((item) => _isAvailable(item['is_available'])).length.toString(),
                Colors.green,
              ),
              _buildStatCard(
                'Indisponibles',
                _menuItems.where((item) => !_isAvailable(item['is_available'])).length.toString(),
                Colors.red,
              ),
            ],
          ),
        ),

        // Menu items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildMenuItemCard(item);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildCategoryCard(Map<String, dynamic> category) {
    final isActive = _isActive(category['is_active']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      // Ajouter une opacité pour les catégories inactives
      child: Opacity(
        opacity: isActive ? 1.0 : 0.7,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isActive ? null : Border.all(color: Colors.red.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category['name'] ?? 'Sans nom',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (category['description'] != null && category['description'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      category['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditCategoryDialog(category),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteCategoryDialog(category),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Supprimer'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildMenuItemCard(Map<String, dynamic> item) {
    final isAvailable = _isAvailable(item['is_available']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.7,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isAvailable ? null : Border.all(color: Colors.red.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] ?? 'Sans nom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isAvailable ? Colors.green : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAvailable ? 'Disponible' : 'Indisponible',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Catégorie: ${item['category'] ?? 'Non définie'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isAvailable ? Colors.grey[600] : Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item['price']?.toStringAsFixed(2) ?? '0.00'} €',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.orange : Colors.orange.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                if (item['description'] != null && item['description'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      item['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isAvailable ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditMenuItemDialog(item),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteMenuItemDialog(item),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Supprimer'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MÉTHODES POUR LES DIALOGS - CATÉGORIES
  // ==========================================

  void _showAddCategoryDialog() {
    CategoryDialogs.showAddCategoryDialog(
      context,
      onSuccess: () {
        _showSuccessSnackBar('Catégorie créée avec succès');
        _loadCategories();
      },
      onError: _showErrorSnackBar,
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    CategoryDialogs.showEditCategoryDialog(
      context,
      category,
      onSuccess: () {
        _showSuccessSnackBar('Catégorie mise à jour avec succès');
        _loadCategories();
      },
      onError: _showErrorSnackBar,
    );
  }

  void _showDeleteCategoryDialog(Map<String, dynamic> category) {
    CategoryDialogs.showDeleteCategoryDialog(
      context,
      category,
      onSuccess: () {
        _showSuccessSnackBar('Catégorie supprimée avec succès');
        _loadCategories();
      },
      onError: _showErrorSnackBar,
    );
  }

  // ==========================================
  // MÉTHODES POUR LES DIALOGS - PLATS
  // ==========================================

  void _showAddMenuItemDialog() {
    MenuItemDialogs.showAddMenuItemDialog(
      context,
      _categories,
      onSuccess: () {
        _showSuccessSnackBar('Plat créé avec succès');
        _loadMenuItems();
      },
      onError: _showErrorSnackBar,
    );
  }

  void _showEditMenuItemDialog(Map<String, dynamic> item) {
    MenuItemDialogs.showEditMenuItemDialog(
      context,
      item,
      _categories,
      onSuccess: () {
        _showSuccessSnackBar('Plat mis à jour avec succès');
        _loadMenuItems();
      },
      onError: _showErrorSnackBar,
    );
  }

  void _showDeleteMenuItemDialog(Map<String, dynamic> item) {
    MenuItemDialogs.showDeleteMenuItemDialog(
      context,
      item,
      onSuccess: () {
        _showSuccessSnackBar('Plat supprimé avec succès');
        _loadMenuItems();
      },
      onError: _showErrorSnackBar,
    );
  }
}