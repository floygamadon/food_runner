import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';
import 'restaurant_menu_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantService = RestaurantService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Home'),
        actions: [
          IconButton(
            onPressed: authService.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Restaurant>>(
        stream: restaurantService.streamRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading restaurants'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final restaurants = snapshot.data!;

          if (restaurants.isEmpty) {
            return const Center(child: Text('No restaurants available yet'));
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: restaurant.imageUrl.isEmpty
                      ? const Icon(Icons.restaurant)
                      : Image.network(
                          restaurant.imageUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                  title: Text(restaurant.name),
                  subtitle: Text(restaurant.description),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantMenuScreen(
                          restaurant: restaurant,
                        ), 
                      ), 
                    );
                  },
                ),
              );
            }, 
          );
        },     
      ),
    );
  }
}