import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class BacklogView extends StatefulWidget {
  const BacklogView({super.key});

  @override
  State<BacklogView> createState() => _BacklogViewState();
}

class _BacklogViewState extends State<BacklogView> {
  // Dummy backlog data
  final List<Map<String, dynamic>> _backlogItems = [
    {
      'id': 1,
      'title': 'Ajouter système de réservation en ligne',
      'description': 'Permettre aux clients de réserver une table directement depuis l\'application',
      'priority': 'High',
      'status': 'In Progress',
      'assignee': 'Équipe Frontend',
      'created_at': '2024-01-10',
    },
    {
      'id': 2,
      'title': 'Intégration système de paiement',
      'description': 'Intégrer Stripe pour les paiements en ligne',
      'priority': 'High',
      'status': 'To Do',
      'assignee': 'Équipe Backend',
      'created_at': '2024-01-12',
    },
    {
      'id': 3,
      'title': 'Système de notifications push',
      'description': 'Notifier les clients des promotions et nouveautés',
      'priority': 'Medium',
      'status': 'To Do',
      'assignee': 'Équipe Mobile',
      'created_at': '2024-01-15',
    },
    {
      'id': 4,
      'title': 'Dashboard analytics',
      'description': 'Tableau de bord pour analyser les ventes et la fréquentation',
      'priority': 'Medium',
      'status': 'Done',
      'assignee': 'Équipe Data',
      'created_at': '2024-01-08',
    },
    {
      'id': 5,
      'title': 'Système de fidélité',
      'description': 'Programme de points de fidélité pour les clients réguliers',
      'priority': 'Low',
      'status': 'To Do',
      'assignee': 'Équipe Product',
      'created_at': '2024-01-18',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Check if user is admin
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
              'Backlog Admin',
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
                icon: const Icon(Icons.add),
                onPressed: () {
                  // TODO: Add new backlog item
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité à venir: Ajouter un élément'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Header with stats
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
                  children: [
                    Text(
                      'Bienvenue, ${authService.currentUser?.fullName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Total', _backlogItems.length.toString(), Colors.white),
                        _buildStatCard('En cours', _backlogItems.where((item) => item['status'] == 'In Progress').length.toString(), Colors.blue),
                        _buildStatCard('Terminé', _backlogItems.where((item) => item['status'] == 'Done').length.toString(), Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Backlog items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _backlogItems.length,
                  itemBuilder: (context, index) {
                    final item = _backlogItems[index];
                    return _buildBacklogItem(item);
                  },
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildBacklogItem(Map<String, dynamic> item) {
    Color statusColor;
    Color priorityColor;

    switch (item['status']) {
      case 'Done':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    switch (item['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['priority'],
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item['assignee'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  item['created_at'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 