import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String restaurantId;
  final List<CartItem> cartItems;

  const CheckoutScreen({
    super.key,
    required this.restaurantId,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();
  final cardNumberController = TextEditingController();
  final nameOnCardController = TextEditingController();
  final expMonthController = TextEditingController();
  final expYearController = TextEditingController();
  final bankNameController = TextEditingController();

  String selectedState = 'GA';

  final List<String> states = const [
    'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
    'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
    'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
    'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY'
  ];

  double get total => widget.cartItems.fold(
        0,
        (sum, item) => sum + item.subtotal,
      );

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text('Total: \$${total.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    final orderId = await OrderService().placeOrder(
      customerId: user.uid,
      restaurantId: widget.restaurantId,
      cartItems: widget.cartItems,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Street'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: zipController,
                decoration: const InputDecoration(labelText: 'Zip Code'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(labelText: 'State'),
                items: states.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (v) => setState(() => selectedState = v!),
              ),
              const SizedBox(height: 20),

              /// Payment
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: nameOnCardController,
                decoration: const InputDecoration(labelText: 'Name on Card'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expMonthController,
                      decoration: const InputDecoration(labelText: 'MM'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: expYearController,
                      decoration: const InputDecoration(labelText: 'YY'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _placeOrder,
                child: Text('Place Order (\$${total.toStringAsFixed(2)})'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}