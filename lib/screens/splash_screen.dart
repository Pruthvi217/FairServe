import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final adminToken = prefs.getString('adminToken');
    if (!mounted) return;
    if (adminToken != null) {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else if (token != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
                  ),
                  child: const Icon(Icons.storefront_rounded, size: 60, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 24),
                const Text('FairServe', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('Smart Ration Management', style: TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1)),
                const SizedBox(height: 48),
                const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
