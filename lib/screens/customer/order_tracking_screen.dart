import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: StreamBuilder<OrderModel>(
        stream: orderService.streamOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading order'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${order.id}'),
                const SizedBox(height: 12),
                Text(
                  'Status: ${order.status.toUpperCase()}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text('Total: \$${order.total.toStringAsFixed(2)}'),
                const SizedBox(height: 20),
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) {
                  return ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text('Qty: ${item['quantity']}'),
                    trailing: Text('\$${item['subtotal']}'),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}