import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'customer/customer_home_screen.dart';
import 'driver/driver_dashboard_screen.dart';
import 'restaurant/restaurant_dashboard_screen.dart';

class RouterScreen extends StatelessWidget {
  const RouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String?>(
          future: authService.getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            if (role == 'restaurant') {
              return const RestaurantDashboardScreen();
            } else if (role == 'driver') {
              return const DriverDashboardScreen();
            } else {
              return const CustomerHomeScreen();
            }
          },
        );
      },
    );
  }
}