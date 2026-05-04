import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/driver_service.dart';
import '../../services/fcm_service.dart';
import 'driver_orders_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final AuthService _authService = AuthService();
  final DriverService _driverService = DriverService();
  final FCMService _fcmService = FCMService();

  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();

    final user = _authService.currentUser;

    if (user != null) {
      _fcmService.initializeAndSaveToken(user.uid);
      _driverService.updateDriverAvailability(
        driverId: user.uid,
        isAvailable: _isAvailable,
      );
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    final user = _authService.currentUser;

    if (user == null) return;

    setState(() {
      _isAvailable = value;
    });

    await _driverService.updateDriverAvailability(
      driverId: user.uid,
      isAvailable: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            onPressed: _authService.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Available for deliveries'),
            subtitle: Text(_isAvailable ? 'Online' : 'Offline'),
            value: _isAvailable,
            onChanged: _toggleAvailability,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.delivery_dining),
            label: const Text('View Driver Orders'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DriverOrdersScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}