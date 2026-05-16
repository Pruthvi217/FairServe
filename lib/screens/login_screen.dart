import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final raw = _phoneCtrl.text.trim();

    if (raw.length != 10 || !RegExp(r'^\d{10}$').hasMatch(raw)) {
      _showSnack('Enter valid 10-digit phone number', Colors.red);
      return;
    }

    setState(() => _loading = true);

    final phone = '+91$raw';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          final result = await FirebaseAuth.instance
              .signInWithCredential(credential);

          if (!mounted) return;

          Navigator.pushReplacementNamed(
            context,
            '/register',
            arguments: {
              'phone': raw,
              'firebaseUid': result.user?.uid ?? '',
            },
          );
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() => _loading = false);

          _showSnack(
            e.message ?? 'Verification failed',
            Colors.red,
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() => _loading = false);

          Navigator.pushNamed(
            context,
            '/otp',
            arguments: {
              'verificationId': verificationId,
              'phone': raw,
            },
          );
        },

        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      setState(() => _loading = false);

      _showSnack(
        'Error: ${e.toString()}',
        Colors.red,
      );
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
            ],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,

              child: Column(
                children: [
                  const SizedBox(height: 60),

                  const Icon(
                    Icons.storefront_rounded,
                    size: 64,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'FairServe',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const Text(
                    'Smart Ration Management',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),

                      padding: const EdgeInsets.all(28),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Login / Register',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Enter your mobile number to continue',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 30),

                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,

                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],

                            decoration: InputDecoration(
                              labelText: 'Mobile Number',

                              prefixIcon: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),

                                child: Text(
                                  '+91 |',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),

                              prefixIconConstraints:
                                  const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),

                              hintText: '9876543210',
                            ),
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                              onPressed:
                                  _loading ? null : _sendOtp,

                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(
                                context,
                                '/admin-login',
                              ),

                              child: const Text(
                                'Admin Login →',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          Center(
                            child: Text(
                              'Protected by Firebase Authentication',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}