import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/models/order_model.dart';

class KitchenDisplayScreen extends StatefulWidget {
  const KitchenDisplayScreen({super.key});

  @override
  State<KitchenDisplayScreen> createState() => _KitchenDisplayScreenState();
}

class _KitchenDisplayScreenState extends State<KitchenDisplayScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} hr ago';
  }

  Color _ticketColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFE74C3C); // red - urgent
      case 'preparing':
        return const Color(0xFFF39C12); // orange
      case 'ready':
        return const Color(0xFF27AE60); // green
      default:
        return const Color(0xFF95A5A6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Kitchen Display — Main St',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('status', whereIn: ['pending', 'preparing'])
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No active orders',
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
            );
          }

          final orders = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final order = OrderModel.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _ticketColor(order.status), width: 3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _ticketColor(order.status),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.userPhone == 'DRIVE-THRU'
                                ? '#DT-${order.id.substring(0, 4)}'
                                : '#APP-${order.id.substring(0, 4)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Text(
                            _timeAgo(order.createdAt),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: order.items
                              .map((item) => Text(
                                    '${item.name}',
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (order.status == 'pending')
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateStatus(order.id, 'preparing'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF39C12)),
                                child: const Text('START',
                                    style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          if (order.status == 'preparing')
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateStatus(order.id, 'ready'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF27AE60)),
                                child: const Text('DONE',
                                    style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}