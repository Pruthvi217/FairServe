import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrlList = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  late String _verificationId;
  late String _phone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _verificationId = args['verificationId'];
    _phone = args['phone'];
  }

  @override
  void dispose() {
    for (var c in _ctrlList) {
      c.dispose();
    }
    for (var n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otp => _ctrlList.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length != 6) { _showSnack('Enter 6-digit OTP', Colors.red); return; }
    setState(() => _loading = true);
    try {
      final credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: _otp);
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/register',
          arguments: {'phone': _phone, 'firebaseUid': result.user?.uid ?? ''});
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      _showSnack(e.message ?? 'Invalid OTP', Colors.red);
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Error: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          const Text('Enter Verification Code', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 8),
          Text('OTP sent to +91-$_phone', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => SizedBox(
              width: 48, height: 56,
              child: TextFormField(
                controller: _ctrlList[i],
                focusNode: _nodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) FocusScope.of(context).requestFocus(_nodes[i + 1]);
                  if (v.isEmpty && i > 0) FocusScope.of(context).requestFocus(_nodes[i - 1]);
                  if (_otp.length == 6) _verify();
                },
              ),
            )),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('← Change Number'),
          )),
        ]),
      ),
    );
  }
}
