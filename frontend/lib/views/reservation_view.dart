import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_view.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reservationData = [];

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  // Simulate API call to fetch reservation data for next 7 days
  Future<void> _loadReservationData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate dummy data for next 7 days
    final now = DateTime.now();
    final List<Map<String, dynamic>> dummyData = [];

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      dummyData.add({
        'date': date.toIso8601String().split('T')[0],
        'display_date': _formatDate(date),
        'day_name': _getDayName(date.weekday),
        'timeslots': [
          {
            'time': '12:00',
            'total_places': 20,
            'available_places': i == 0 ? 5 : (i == 1 ? 0 : 15 - (i * 2)),
          },
          {
            'time': '13:30',
            'total_places': 20,
            'available_places': i == 0 ? 8 : (i == 2 ? 1 : 12 - (i * 1)),
          },
          {
            'time': '19:00',
            'total_places': 25,
            'available_places': i == 0 ? 12 : (i == 3 ? 0 : 18 - (i * 2)),
          },
          {
            'time': '20:30',
            'total_places': 25,
            'available_places': i == 0 ? 15 : (i == 1 ? 3 : 20 - (i * 2)),
          },
        ],
      });
    }

    setState(() {
      _reservationData = dummyData;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getDayName(int weekday) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Réservations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReservationData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReservationData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
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
                      child: const Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 50,
                            color: Colors.white,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Réserver votre table',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choisissez votre créneau pour les 7 prochains jours',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Reservation slots
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _reservationData.map((dayData) {
                          return _buildDayCard(dayData);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> dayData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dayData['day_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dayData['display_date'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time slots
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (dayData['timeslots'] as List).map((slot) {
                return _buildTimeSlot(
                  dayData['date'],
                  slot['time'],
                  slot['total_places'],
                  slot['available_places'],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String date, String time, int totalPlaces, int availablePlaces) {
    final bool isAvailable = availablePlaces > 0;
    
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2 - 4,
      child: ElevatedButton(
        onPressed: isAvailable
            ? () => _handleReservationTap(date, time, availablePlaces)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAvailable ? Colors.orange : Colors.grey[300],
          foregroundColor: isAvailable ? Colors.white : Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isAvailable ? 2 : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAvailable ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAvailable 
                  ? '$availablePlaces/$totalPlaces places'
                  : 'Complet',
              style: TextStyle(
                fontSize: 12,
                color: isAvailable ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReservationTap(String date, String time, int availablePlaces) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.isAuthenticated) {
      // Redirect to login if not authenticated
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginView(),
        ),
      );
      return;
    }

    // Show reservation modal
    _showReservationModal(date, time, availablePlaces);
  }

  void _showReservationModal(String date, String time, int availablePlaces) {
    final TextEditingController personsController = TextEditingController();
    bool isValidPersonCount = true;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text(
                'Réserver une table',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reservation details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              date,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              time,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              '$availablePlaces places disponibles',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Number of persons input
                  TextField(
                    controller: personsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Nombre de personnes',
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isValidPersonCount ? Colors.grey : Colors.red,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isValidPersonCount ? Colors.orange : Colors.red,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      errorText: !isValidPersonCount 
                          ? 'Trop de personnes pour ce créneau'
                          : null,
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        final personCount = int.tryParse(value) ?? 0;
                        isValidPersonCount = personCount > 0 && personCount <= availablePlaces;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isValidPersonCount && personsController.text.isNotEmpty
                      ? () {
                          _confirmReservation(
                            date,
                            time,
                            int.parse(personsController.text),
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValidPersonCount ? Colors.orange : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmReservation(String date, String time, int persons) {
    // TODO: This will later make an API call to create the reservation
    // For now, just show a success message
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Réservation confirmée pour $persons personne${persons > 1 ? 's' : ''} le $date à $time',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Refresh the data to update available places
    _loadReservationData();
  }
} 