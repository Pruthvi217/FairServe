import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@fairserve.com');
  final _passCtrl = TextEditingController(text: 'admin123');
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.adminLogin(_emailCtrl.text.trim(), _passCtrl.text);
      setState(() => _loading = false);
      if (res['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('adminToken', res['token']);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Login failed'), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: SafeArea(child: Column(children: [
        const SizedBox(height: 60),
        const Icon(Icons.admin_panel_settings, size: 70, color: Colors.white),
        const SizedBox(height: 12),
        const Text('Admin Panel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const Text('FairServe Management', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 40),
        Expanded(child: Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            const SizedBox(height: 8),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Admin Email', prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 16),
            TextField(controller: _passCtrl, obscureText: _obscure, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure = !_obscure)))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB)),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login as Admin', style: TextStyle(fontSize: 16)),
            )),
            const SizedBox(height: 16),
            TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Back to User Login')),
          ]),
        )),
      ])),
    ),
  );
}
