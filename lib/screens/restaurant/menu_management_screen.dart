import 'package:flutter/material.dart';

import '../../models/menu_item.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addMenuItem() async {
    final user = _authService.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final item = MenuItemModel(
        id: '',
        restaurantId: user.uid,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        imageUrl: '',
      );

      await _restaurantService.addMenuItem(item);

      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu item added')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food name',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _addMenuItem,
              child: Text(_isLoading ? 'Adding...' : 'Add Menu Item'),
            ),
            const Divider(height: 32),
            Expanded(
              child: StreamBuilder<List<MenuItemModel>>(
                stream: _restaurantService.streamMenuItems(restaurantId),
                builder: (context, snapshot) {
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

                      return ListTile(
                        leading: const Icon(Icons.fastfood),
                        title: Text(item.name),
                        subtitle: Text(item.description),
                        trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}