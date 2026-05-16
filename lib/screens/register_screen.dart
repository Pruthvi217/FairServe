import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  bool _loading = false;
  late String _phone;
  late String _firebaseUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _phone = args['phone'];
    _firebaseUid = args['firebaseUid'] ?? '';
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.registerOrLogin(phone: _phone, firebaseUid: _firebaseUid);
      if (res['success'] == true && res['needsRegistration'] != true) {
        await _saveAndNavigate(res);
        return;
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.registerOrLogin(
        phone: _phone,
        name: _nameCtrl.text.trim(),
        rationCardNumber: _cardCtrl.text.trim().toUpperCase(),
        firebaseUid: _firebaseUid,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        await _saveAndNavigate(res);
      } else {
        setState(() => _loading = false);
        _showSnack(res['message'] ?? 'Registration failed', Colors.red);
      }
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Error: $e', Colors.red);
    }
  }

  Future<void> _saveAndNavigate(Map res) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', res['token']);
    await prefs.setString('userName', res['user']['name'] ?? '');
    await prefs.setString('userPhone', _phone);
    await prefs.setString('rationCard', res['user']['rationCardNumber'] ?? '');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  void dispose() { _nameCtrl.dispose(); _cardCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: _loading
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(), SizedBox(height: 16), Text('Please wait...')
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      Expanded(child: Text('New account for +91-$_phone', style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w500))),
                    ]),
                  ),
                  const SizedBox(height: 28),
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(hintText: 'Enter your full name', prefixIcon: Icon(Icons.person)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text('Ration Card Number', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cardCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'e.g. KA/BPL/123456', prefixIcon: Icon(Icons.credit_card)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ration card number is required' : null,
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Register & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }
}
