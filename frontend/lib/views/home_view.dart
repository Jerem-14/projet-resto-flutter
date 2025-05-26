import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Fake JSON data for menu items
  final List<Map<String, dynamic>> _fakeMenuData = [
    {
      'id': 1,
      'category': 'Entrées',
      'name': 'Salade César',
      'description': 'Salade fraîche avec croûtons, parmesan et sauce César maison',
      'price': 12.50,
      'is_available': true,
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
    {
      'id': 2,
      'category': 'Plats principaux',
      'name': 'Saumon grillé',
      'description': 'Filet de saumon grillé avec légumes de saison et riz basmati',
      'price': 24.90,
      'is_available': true,
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
    {
      'id': 3,
      'category': 'Plats principaux',
      'name': 'Bœuf bourguignon',
      'description': 'Bœuf mijoté au vin rouge avec pommes de terre et carottes',
      'price': 22.00,
      'is_available': false,
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
    {
      'id': 4,
      'category': 'Desserts',
      'name': 'Tarte aux pommes',
      'description': 'Tarte aux pommes maison avec glace vanille',
      'price': 8.50,
      'is_available': true,
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
     {
      'id': 4,
      'category': 'Desserts2',
      'name': 'Tarte aux pommes',
      'description': 'Tarte aux pommes maison avec glace vanille',
      'price': 8.50,
      'is_available': true,
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
    {
      'id': 5,
      'category': 'Boissons',
      'name': 'Vin rouge',
      'description': 'Bordeaux rouge, millésime 2020',
      'price': 6.00,
      'is_available': true,
      'created_at': '2024-01-15T10:00:00Z',
      'updated_at': '2024-01-15T10:00:00Z',
    },
  ];

  late List<MenuItem> _menuItems;
  Map<String, List<MenuItem>> _groupedMenuItems = {};

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  void _loadMenuItems() {
    _menuItems = _fakeMenuData.map((json) => MenuItem.fromJson(json)).toList();
    _groupMenuItemsByCategory();
  }

  void _groupMenuItemsByCategory() {
    _groupedMenuItems = {};
    for (var item in _menuItems) {
      if (!_groupedMenuItems.containsKey(item.category)) {
        _groupedMenuItems[item.category] = [];
      }
      _groupedMenuItems[item.category]!.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurant Délice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue !',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Découvrez notre délicieuse cuisine française dans une ambiance chaleureuse.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notre Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Menu Items by Category
                  ..._groupedMenuItems.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        ...entry.value.map((item) => _buildMenuItem(item)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Indisponible',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${item.price.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 