import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../services/restaurant_service.dart';
import 'checkout_screen.dart';

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

  Future<void> _checkout() async {
    final selectedItems = _quantities.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item')),
      );
      return;
    }

    final restaurantService = RestaurantService();

    restaurantService.streamMenuItems(widget.restaurant.id).first.then((items) {
      final cartItems = selectedItems.map((entry) {
        final item = items.firstWhere((i) => i.id == entry.key);

        return CartItem(
          menuItem: item,
          quantity: entry.value,
        );
      }).toList();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            restaurantId: widget.restaurant.id,
            cartItems: cartItems,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantService = RestaurantService();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: _checkout,
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Checkout'),
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