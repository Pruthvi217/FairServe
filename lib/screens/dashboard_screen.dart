import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'map_screen.dart';
import 'slots_screen.dart';
import 'my_bookings_screen.dart';
import 'ration_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _userName = '';
  String _phone = '';
  String _rationCard = '';
  Map<String, dynamic>? _quota;
  final int _activeBookings = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    MapScreen(),
    SlotsScreen(),
    MyBookingsScreen(),
    RationScreen(),
  ];

  @override
  void initState() { super.initState(); _loadUser(); }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _phone = prefs.getString('userPhone') ?? '';
      _rationCard = prefs.getString('rationCard') ?? '';
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Slots'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Ration'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _userName = '';
  String _rationCard = '';
  String _category = 'BPL';
  Map<String, dynamic>? _quota;
  int _activeBookings = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? 'User';
    _rationCard = prefs.getString('rationCard') ?? '';
    try {
      final quotaRes = await ApiService.getQuota();
      final bookRes = await ApiService.getMyBookings();
      if (mounted) {
        setState(() {
        _quota = quotaRes['success'] == true ? quotaRes : null;
        _category = quotaRes['category'] ?? 'BPL';
        if (bookRes['success'] == true) {
          final bookings = bookRes['bookings'] as List;
          _activeBookings = bookings.where((b) => b['status'] == 'confirmed').length;
        }
        _loading = false;
      });
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'), content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FairServe'),
        actions: [
          IconButton(icon: const Icon(Icons.person_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.waving_hand, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome, $_userName!', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Card: $_rationCard', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: Text(_category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  _StatChip(Icons.bookmark_added, '$_activeBookings', 'Bookings'),
                  const SizedBox(width: 12),
                  const _StatChip(Icons.check_circle, '0', 'Collected'),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            // Quick actions
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
              children: [
                _ActionCard(Icons.map_rounded, 'Find Shops', 'Nearby shops', const Color(0xFF1565C0), () => _navigate(1)),
                _ActionCard(Icons.calendar_month, 'Book Slot', 'Reserve your slot', const Color(0xFF6A1B9A), () => _navigate(2)),
                _ActionCard(Icons.bookmark_rounded, 'My Bookings', 'View bookings', const Color(0xFFE65100), () => _navigate(3)),
                _ActionCard(Icons.inventory_2_rounded, 'My Ration', 'Monthly quota', const Color(0xFF00695C), () => _navigate(4)),
              ],
            ),
            const SizedBox(height: 20),
            // Monthly quota
            if (_quota != null) ...[
              const Text('Monthly Quota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Your Entitlements', style: TextStyle(fontWeight: FontWeight.w600)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)), child: Text('Family: ${_quota!['familySize']}', style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    ...(_quota!['quota'] as Map<String, dynamic>? ?? {}).entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.grain, size: 16, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 8),
                        Text(e.key[0].toUpperCase() + e.key.substring(1), style: const TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('${e.value} kg/L', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                      ]),
                    )),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigate(int index) {
    final parent = context.findAncestorStateOfType<_DashboardScreenState>();
    parent?.setState(() => parent._currentIndex = index);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon; final String value; final String label;
  const _StatChip(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 16),
      const SizedBox(width: 6),
      Text('$value $label', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _ActionCard(this.icon, this.title, this.subtitle, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 22)),
        const Spacer(),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(subtitle, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
      ]),
    ),
  );
}
