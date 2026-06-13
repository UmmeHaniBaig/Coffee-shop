import 'package:flutter/material.dart';
import 'package:coffee_app/services/auth_service.dart';
import 'package:coffee_app/screens/login_screen.dart';
import 'package:coffee_app/screens/menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'Coffee Shop',
          style: TextStyle(color: Color(0xFFD4A96A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD4A96A)),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.coffee, size: 100, color: Color(0xFFD4A96A)),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.displayName ?? 'Coffee Lover'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4A96A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your coffee is brewing...',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MenuScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A96A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.coffee_maker, color: Colors.white),
                label: const Text(
                  'View Menu',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}