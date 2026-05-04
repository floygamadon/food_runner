import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';

class RestaurantOrdersScreen extends StatelessWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final orderService = OrderService();

    final restaurantId =  'DHZtpy71DgRZBVIJwMWGmQOCmrq2';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Orders'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.streamRestaurantOrders(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
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
                    'Status: ${order.status}\nTotal: \$${order.total.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (status) {
                      orderService.updateOrderStatus(
                        orderId: order.id,
                        status: status,
                      );
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'confirmed',
                          child: Text('Confirmed'),
                        ),
                        PopupMenuItem(
                          value: 'preparing',
                          child: Text('Preparing'),
                        ),
                        PopupMenuItem(
                          value: 'ready_for_pickup',
                          child: Text('Ready for Pickup'),
                        ),
                      ];
                    },
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