class OrderModel {
  final String id;
  final String customerId;
  final String restaurantId;
  final String status;
  final String driverId;
  final double total;
  final List<dynamic> items;
  final DateTime? createdAt;
  final bool reviewed;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.status,
    required this.driverId,
    required this.total,
    required this.items,
    required this.createdAt,
    required this.reviewed,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      customerId: data['customerId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      status: data['status'] ?? 'placed',
      driverId: data['driverId'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      items: data['items'] ?? [],
      createdAt: data['createdAt']?.toDate(),
      reviewed: data['reviewed'] ?? false,
    );
  }
}