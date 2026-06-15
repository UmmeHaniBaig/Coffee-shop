import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> placeOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userPhone) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userPhone', isEqualTo: userPhone)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}