import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import 'review_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final orderService = OrderService();

    final customerId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.streamCompletedCustomerOrders(customerId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading order history'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return const Center(child: Text('No completed orders yet'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text('Order ${order.id}'),
                  subtitle: Text(
                    'Total: \$${order.total.toStringAsFixed(2)}\nStatus: ${order.status}',
                  ),
                  isThreeLine: true,
                  trailing: order.reviewed
                      ? const Text('Reviewed')
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewScreen(order: order),
                              ),
                            );
                          },
                          child: const Text('Review'),
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