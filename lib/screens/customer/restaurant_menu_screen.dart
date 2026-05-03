import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../services/restaurant_service.dart';

class RestaurantMenuScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantMenuScreen({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final restaurantService = RestaurantService();

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: restaurantService.streamMenuItems(restaurant.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading menu'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(child: Text('No menu items yet'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: item.imageUrl.isEmpty
                      ? const Icon(Icons.fastfood)
                      : Image.network(
                          item.imageUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}