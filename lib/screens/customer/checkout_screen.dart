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
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
  ];

  double get subtotal => widget.cartItems.fold(
        0,
        (sum, item) => sum + item.subtotal,
      );

  double get tax => subtotal * 0.06;

  double get grandTotal => subtotal + tax;

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
            Text('Tax (6%): \$${tax.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              'Total: \$${grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    streetController.dispose();
    cityController.dispose();
    zipController.dispose();
    cardNumberController.dispose();
    nameOnCardController.dispose();
    expMonthController.dispose();
    expYearController.dispose();
    bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Street Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: zipController,
                decoration: const InputDecoration(labelText: 'Zip Code'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(labelText: 'State'),
                items: states.map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Credit Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: nameOnCardController,
                decoration: const InputDecoration(labelText: 'Name on Card'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expMonthController,
                      decoration: const InputDecoration(labelText: 'Expiration Month'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: expYearController,
                      decoration: const InputDecoration(labelText: 'Expiration Year'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _summaryRow('Subtotal', subtotal),
                    _summaryRow('Tax (6%)', tax),
                    const Divider(),
                    _summaryRow('Grand Total', grandTotal, bold: true),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _placeOrder,
                child: Text(
                  'Place Order (\$${grandTotal.toStringAsFixed(2)})',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}