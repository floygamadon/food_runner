import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'menu_management_screen.dart';
import 'restaurant_orders_screen.dart';

class RestaurantDashboardScreen extends StatelessWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        actions: [
          IconButton(
            onPressed: authService.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.menu_book),
            label: const Text('Manage Menu'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MenuManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: const Text('View Incoming Orders'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantOrdersScreen(),
                ),
              );
            }, 
          ), 
        ],
      ),
    );
  }
}