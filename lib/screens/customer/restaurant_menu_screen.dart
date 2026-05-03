import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/restaurant_service.dart';
import 'order_tracking_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMenuScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final Map<String, int> _quantities = {};

  void _increase(String itemId) {
    setState(() {
      _quantities[itemId] = (_quantities[itemId] ?? 0) + 1;
    });
  }

  void _decrease(String itemId) {
    setState(() {
      final current = _quantities[itemId] ?? 0;

      if (current > 0) {
        _quantities[itemId] = current - 1;
      }
    });
  }

  Future<void> _quickOrder({
    required BuildContext context,
    required MenuItemModel item,
  }) async {
    final user = AuthService().currentUser;

    if (user == null) return;

    final quantity = _quantities[item.id] ?? 0;

    if (quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 item')),
      );
      return;
    }

    final orderId = await OrderService().placeOrder(
      customerId: user.uid,
      restaurantId: widget.restaurant.id,
      cartItems: [
        CartItem(
          menuItem: item,
          quantity: quantity,
        ),
      ],
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantService = RestaurantService();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: restaurantService.streamMenuItems(widget.restaurant.id),
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
              final quantity = _quantities[item.id] ?? 0;

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      item.imageUrl.isEmpty
                          ? const Icon(Icons.fastfood)
                          : Image.network(
                              item.imageUrl,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name),
                            Text(item.description),
                            const SizedBox(height: 8), 
                            Text('\$${item.price.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _increase(item.id),
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _decrease(item.id),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              _quickOrder(
                                context: context,
                                item: item,
                              );
                            },
                            child: const Text('Order'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}