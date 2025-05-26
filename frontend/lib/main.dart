import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'views/home_view.dart';
import 'views/reservation_view.dart';
import 'views/profile_view.dart';

void main() {
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'Restaurant App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const MainNavigationView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomeView(),
    const ReservationView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        return Scaffold(
          body: _views[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              
              // Clear notification when user taps on profile
              if (index == 2 && notificationService.hasNewReservation) {
                notificationService.clearNewReservation();
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'HOME',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: 'RESERVATION',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.person),
                    if (notificationService.hasNewReservation)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'PROFILE',
              ),
            ],
          ),
        );
      },
    );
  }
}
