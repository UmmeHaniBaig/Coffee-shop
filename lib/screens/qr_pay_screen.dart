import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:coffee_app/services/phone_auth_service.dart';
import 'package:coffee_app/services/loyalty_service.dart';
import 'package:coffee_app/models/loyalty_model.dart';

class QRPayScreen extends StatefulWidget {
  const QRPayScreen({super.key});

  @override
  State<QRPayScreen> createState() => _QRPayScreenState();
}

class _QRPayScreenState extends State<QRPayScreen> {
  final PhoneAuthService _authService = PhoneAuthService();
  final LoyaltyService _loyaltyService = LoyaltyService();
  LoyaltyModel? _loyalty;

  @override
  void initState() {
    super.initState();
    _loadLoyalty();
  }

  Future<void> _loadLoyalty() async {
    final phone = _authService.currentUser?.phoneNumber ?? '';
    final loyalty = await _loyaltyService.getLoyalty(phone);
    setState(() => _loyalty = loyalty);
  }

  // Returns (nextTierName, targetStars, progress 0-1)
  (String, int, double) _getTierProgress(int stars) {
    if (stars < 100) {
      return ('Silver', 100, stars / 100);
    } else if (stars < 200) {
      return ('Gold', 200, (stars - 100) / 100);
    } else {
      return ('Max Tier', 200, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = _authService.currentUser?.phoneNumber ?? 'Guest';
    final stars = _loyalty?.stars ?? 0;
    final tier = _loyalty?.tier ?? 'Bronze';
    final (nextTier, targetStars, progress) = _getTierProgress(stars);

    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text('Scan in Store',
            style: TextStyle(color: Color(0xFFD4A96A))),
        iconTheme: const IconThemeData(color: Color(0xFFD4A96A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Balance / Stars Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A96A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STARS',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 1)),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 28),
                              const SizedBox(width: 4),
                              Text(
                                '$stars',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('TIER',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 1)),
                          Text(
                            tier,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  if (nextTier != 'Max Tier') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${targetStars - stars} more to $nextTier',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '$stars / $targetStars',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ] else
                    const Text(
                      '🎉 You\'ve reached the highest tier!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // QR Code
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'SHOW THIS CODE',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'to earn stars & pay',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: phone,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Member ID: $phone',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}