import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/driver_service.dart';

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final driverService = DriverService();

    final driverId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Orders'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Available Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: driverService.streamAvailableOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!;

                if (orders.isEmpty) {
                  return const Center(child: Text('No available orders'));
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
                        trailing: ElevatedButton(
                          onPressed: () {
                            driverService.acceptOrder(
                              orderId: order.id,
                              driverId: driverId,
                            );
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'My Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: driverService.streamDriverOrders(driverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading deliveries'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!;

                if (orders.isEmpty) {
                  return const Center(child: Text('No assigned deliveries'));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text('Delivery ${order.id}'),
                        subtitle: Text(
                          'Status: ${order.status}\nTotal: \$${order.total.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (status) {
                            driverService.updateDeliveryStatus(
                              orderId: order.id,
                              status: status,
                            );
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem(
                                value: 'picked_up',
                                child: Text('Picked Up'),
                              ),
                              PopupMenuItem(
                                value: 'on_the_way',
                                child: Text('On The Way'),
                              ),
                              PopupMenuItem(
                                value: 'delivered',
                                child: Text('Delivered'),
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
          ),
        ],
      ),
    );
  }
}