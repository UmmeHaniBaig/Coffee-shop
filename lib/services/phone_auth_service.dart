import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(User?) onAutoVerified,
  }) async {
    try {
      print('Sending OTP to: $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto-verified!');
          UserCredential result = await _auth.signInWithCredential(credential);
          onAutoVerified(result.user);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification FAILED: ${e.code} - ${e.message}');
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code sent! Verification ID: $verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout. Verification ID: $verificationId');
        },
      );
    } catch (e) {
      print('Send OTP exception: $e');
      onError(e.toString());
    }
  }

  // Verify OTP code
  Future<User?> verifyOTP(String otp, String verificationId) async {
    try {
      print('Verifying OTP: $otp with verificationId: $verificationId');
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      print('Sign in successful: ${result.user?.uid}');
      return result.user;
    } catch (e) {
      print('Verify OTP exception: $e');
      throw Exception(e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if logged in
  bool get isLoggedIn => _auth.currentUser != null;
}