import 'package:coffee_app/models/product_model.dart';

class OrderModel {
  final String id;
  final String userPhone;
  final List<ProductModel> items;
  final double total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userPhone,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userPhone': userPhone,
      'items': items
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'price': item.price,
                'imageUrl': item.imageUrl,
              })
          .toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      userPhone: data['userPhone'] ?? '',
      items: (data['items'] as List<dynamic>)
          .map((item) => ProductModel(
                id: item['id'] ?? '',
                name: item['name'] ?? '',
                price: (item['price'] ?? 0).toDouble(),
                description: '',
                category: '',
                imageUrl: item['imageUrl'] ?? '',
              ))
          .toList(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}