import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tab = 0;
  Map<String, dynamic>? _stats;

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    try {
      final res = await ApiService.getAdminStats();
      if (res['success'] == true && mounted) setState(() => _stats = res['stats']);
    } catch (_) {}
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminToken');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final tabTitles = ['Dashboard', 'Shops', 'Slots', 'Users', 'Bookings'];
    final bodies = [
      _DashTab(stats: _stats, onRefresh: _loadStats),
      const _ShopsTab(),
      const _SlotsTab(),
      const _UsersTab(),
      const _BookingsTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: Text('Admin · ${tabTitles[_tab]}', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Logout')],
      ),
      body: bodies[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) { setState(() => _tab = i); if (i == 0) _loadStats(); },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), activeIcon: Icon(Icons.store), label: 'Shops'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Slots'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outlined), activeIcon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Bookings'),
        ],
      ),
    );
  }
}

// ── DASHBOARD TAB ─────────────────────────────────────────────────────────────
class _DashTab extends StatelessWidget {
  final Map<String, dynamic>? stats; final VoidCallback onRefresh;
  const _DashTab({this.stats, required this.onRefresh});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async => onRefresh(),
    child: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]), borderRadius: BorderRadius.circular(18)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.admin_panel_settings, color: Colors.white, size: 28), SizedBox(width: 10), Text('FairServe Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
          SizedBox(height: 4),
          Text('Smart Ration Management System', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 20),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
        children: [
          _StatCard('Total Users', '${stats?['users'] ?? 0}', Icons.people, const Color(0xFF1565C0)),
          _StatCard('Active Shops', '${stats?['shops'] ?? 0}', Icons.store, const Color(0xFF2E7D32)),
          _StatCard('Total Slots', '${stats?['slots'] ?? 0}', Icons.calendar_today, const Color(0xFF6A1B9A)),
          _StatCard('Confirmed Bookings', '${stats?['bookings'] ?? 0}', Icons.bookmark, const Color(0xFFE65100)),
        ],
      ),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String label; final String value; final IconData icon; final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 28),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
    ]),
  );
}

// ── SHOPS TAB ─────────────────────────────────────────────────────────────────
class _ShopsTab extends StatefulWidget {
  const _ShopsTab();
  @override
  State<_ShopsTab> createState() => _ShopsTabState();
}

class _ShopsTabState extends State<_ShopsTab> {
  List<dynamic> _shops = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getAdminShops();
      if (mounted) setState(() { _shops = res['success'] == true ? res['shops'] : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _showCreateShop() => showModalBottomSheet(
    context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _CreateShopSheet(onCreated: _load),
  );

  void _showStockUpdate(dynamic shop) => showModalBottomSheet(
    context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _UpdateStockSheet(shop: shop, onUpdated: _load),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showCreateShop,
      backgroundColor: const Color(0xFF1A237E),
      icon: const Icon(Icons.add), label: const Text('Add Shop'),
    ),
    body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
      onRefresh: _load,
      child: _shops.isEmpty
          ? const Center(child: Text('No shops yet. Add one!'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _shops.length,
              itemBuilder: (_, i) {
                final s = _shops[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.store, color: Color(0xFF2E7D32))),
                    title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s['address'] ?? '', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Dealer: ${s['dealerName'] ?? '-'}  •  📞 ${s['phone'] ?? '-'}', style: const TextStyle(fontSize: 11)),
                    ]),
                    trailing: IconButton(icon: const Icon(Icons.inventory, color: Color(0xFF2E7D32)), onPressed: () => _showStockUpdate(s), tooltip: 'Update Stock'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    ),
  );
}

class _CreateShopSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateShopSheet({required this.onCreated});
  @override
  State<_CreateShopSheet> createState() => _CreateShopSheetState();
}

class _CreateShopSheetState extends State<_CreateShopSheet> {
  final _name = TextEditingController();
  final _dealer = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _lat = TextEditingController(text: '12.9716');
  final _lng = TextEditingController(text: '77.5946');
  bool _loading = false;

  Future<void> _submit() async {
    if (_name.text.isEmpty || _address.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and address required'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.createShop({
        'name': _name.text.trim(), 'dealerName': _dealer.text.trim(),
        'address': _address.text.trim(), 'phone': _phone.text.trim(),
        'lat': double.tryParse(_lat.text) ?? 12.9716,
        'lng': double.tryParse(_lng.text) ?? 77.5946,
      });
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop created!'), backgroundColor: Colors.green));
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed'), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Create New Shop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Shop Name *')),
      const SizedBox(height: 12),
      TextField(controller: _dealer, decoration: const InputDecoration(labelText: 'Dealer Name')),
      const SizedBox(height: 12),
      TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address *'), maxLines: 2),
      const SizedBox(height: 12),
      TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: TextField(controller: _lat, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Latitude'))),
        const SizedBox(width: 12),
        Expanded(child: TextField(controller: _lng, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Longitude'))),
      ]),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Shop'),
      )),
    ])),
  );
}

class _UpdateStockSheet extends StatefulWidget {
  final dynamic shop; final VoidCallback onUpdated;
  const _UpdateStockSheet({required this.shop, required this.onUpdated});
  @override
  State<_UpdateStockSheet> createState() => _UpdateStockSheetState();
}

class _UpdateStockSheetState extends State<_UpdateStockSheet> {
  late Map<String, TextEditingController> _ctrls;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final stock = widget.shop['stock'] ?? {};
    _ctrls = {
      'rice': TextEditingController(text: '${stock['rice'] ?? 0}'),
      'wheat': TextEditingController(text: '${stock['wheat'] ?? 0}'),
      'sugar': TextEditingController(text: '${stock['sugar'] ?? 0}'),
      'kerosene': TextEditingController(text: '${stock['kerosene'] ?? 0}'),
      'pulses': TextEditingController(text: '${stock['pulses'] ?? 0}'),
    };
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final stock = _ctrls.map((k, v) => MapEntry(k, int.tryParse(v.text) ?? 0));
    try {
      final res = await ApiService.updateStock(widget.shop['_id'], stock);
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pop(context); widget.onUpdated();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock updated!'), backgroundColor: Colors.green));
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed'), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Update Stock: ${widget.shop['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      ...(_ctrls.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: e.value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${e.key[0].toUpperCase()}${e.key.substring(1)} (kg/L)')),
      ))),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Update Stock'),
      )),
    ]),
  );
}

// ── SLOTS TAB ─────────────────────────────────────────────────────────────────
class _SlotsTab extends StatefulWidget {
  const _SlotsTab();
  @override
  State<_SlotsTab> createState() => _SlotsTabState();
}

class _SlotsTabState extends State<_SlotsTab> {
  List<dynamic> _slots = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getAdminSlots();
      if (mounted) setState(() { _slots = res['success'] == true ? res['slots'] : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _showCreateSlot() => showModalBottomSheet(
    context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _CreateSlotSheet(onCreated: _load),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showCreateSlot,
      backgroundColor: const Color(0xFF1A237E),
      icon: const Icon(Icons.add), label: const Text('Add Slot'),
    ),
    body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
      onRefresh: _load,
      child: _slots.isEmpty
          ? const Center(child: Text('No slots yet. Create one!'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _slots.length,
              itemBuilder: (_, i) {
                final s = _slots[i];
                final fill = (s['bookedCount'] ?? 0) / (s['capacity'] ?? 30);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(s['shopName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: fill >= 1.0 ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                        child: Text(fill >= 1.0 ? 'Full' : 'Open', style: TextStyle(color: fill >= 1.0 ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text('${s['date']}  •  ${s['time']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('${s['bookedCount'] ?? 0}/${s['capacity'] ?? 30} booked', style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text('${(fill * 100).toInt()}% full', style: TextStyle(fontSize: 12, color: fill >= 0.8 ? Colors.red : Colors.grey)),
                    ]),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: fill.clamp(0.0, 1.0), backgroundColor: Colors.grey.shade200, color: fill >= 1.0 ? Colors.red : (fill >= 0.7 ? Colors.orange : Colors.green), minHeight: 6, borderRadius: BorderRadius.circular(4)),
                  ])),
                );
              },
            ),
    ),
  );
}

class _CreateSlotSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateSlotSheet({required this.onCreated});
  @override
  State<_CreateSlotSheet> createState() => _CreateSlotSheetState();
}

class _CreateSlotSheetState extends State<_CreateSlotSheet> {
  List<dynamic> _shops = [];
  String? _shopId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _time = '09:00 AM';
  int _capacity = 30;
  bool _loading = false;
  bool _loadingShops = true;

  final _times = ['08:00 AM','09:00 AM','10:00 AM','11:00 AM','12:00 PM','01:00 PM','02:00 PM','03:00 PM','04:00 PM','05:00 PM'];

  @override
  void initState() { super.initState(); _loadShops(); }

  Future<void> _loadShops() async {
    try {
      final res = await ApiService.getAdminShops();
      if (mounted) setState(() { _shops = res['success'] == true ? res['shops'] : []; _loadingShops = false; });
    } catch (_) { if (mounted) setState(() => _loadingShops = false); }
  }

  Future<void> _submit() async {
    if (_shopId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a shop'), backgroundColor: Colors.red)); return; }
    setState(() => _loading = true);
    try {
      final res = await ApiService.createSlot({'shopId': _shopId, 'date': DateFormat('yyyy-MM-dd').format(_date), 'time': _time, 'capacity': _capacity});
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pop(context); widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot created!'), backgroundColor: Colors.green));
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed'), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Create New Slot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      if (_loadingShops) const Center(child: CircularProgressIndicator())
      else DropdownButtonFormField<String>(
        initialValue: _shopId, hint: const Text('Select Shop'),
        decoration: const InputDecoration(labelText: 'Shop', border: OutlineInputBorder()),
        items: _shops.map<DropdownMenuItem<String>>((s) => DropdownMenuItem(value: s['_id'], child: Text(s['name'], overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => setState(() => _shopId = v),
      ),
      const SizedBox(height: 12),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Date'), trailing: Text(DateFormat('dd MMM yyyy').format(_date), style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)));
          if (d != null) setState(() => _date = d);
        },
      ),
      const Divider(),
      DropdownButtonFormField<String>(
        initialValue: _time, decoration: const InputDecoration(labelText: 'Time Slot', border: OutlineInputBorder()),
        items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _time = v!),
      ),
      const SizedBox(height: 12),
      Row(children: [
        const Text('Capacity (max users):'), const Spacer(),
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { if (_capacity > 5) setState(() => _capacity -= 5); }),
        Text('$_capacity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () { if (_capacity < 100) setState(() => _capacity += 5); }),
      ]),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Slot'),
      )),
    ])),
  );
}

// ── USERS TAB ─────────────────────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<dynamic> _users = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getAdminUsers();
      if (mounted) setState(() { _users = res['success'] == true ? res['users'] : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) =>
      (u['name'] ?? '').toLowerCase().contains(_search.toLowerCase()) ||
      (u['phone'] ?? '').contains(_search) ||
      (u['rationCardNumber'] ?? '').toLowerCase().contains(_search.toLowerCase())
    ).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(hintText: 'Search users...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final u = filtered[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFF2E7D32), child: Text((u['name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                title: Text(u['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('+91-${u['phone'] ?? ''}'),
                  Text('Card: ${u['rationCardNumber'] ?? ''}', style: const TextStyle(fontSize: 12)),
                ]),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                  child: Text(u['category'] ?? 'BPL', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600, fontSize: 12)),
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      )),
    ]);
  }
}

// ── BOOKINGS TAB ──────────────────────────────────────────────────────────────
class _BookingsTab extends StatefulWidget {
  const _BookingsTab();
  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getAdminBookings();
      if (mounted) setState(() { _bookings = res['success'] == true ? res['bookings'] : []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _markComplete(String id) async {
    try {
      final res = await ApiService.completeBooking(id);
      if (res['success'] == true) { _load(); }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _load,
          child: _bookings.isEmpty
              ? const Center(child: Text('No bookings found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (_, i) {
                    final b = _bookings[i];
                    final user = b['userId'];
                    final status = b['status'] ?? 'confirmed';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(user is Map ? (user['name'] ?? 'Unknown') : 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(user is Map ? '+91-${user['phone'] ?? ''}' : '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: status == 'confirmed' ? Colors.green.shade50 : status == 'completed' ? Colors.blue.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Text(status, style: TextStyle(color: status == 'confirmed' ? Colors.green : status == 'completed' ? Colors.blue : Colors.red, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text('Shop: ${b['shopName'] ?? ''}  •  Token: #${b['tokenNumber'] ?? '-'}', style: const TextStyle(fontSize: 13)),
                        Text('${b['date']}  •  ${b['time']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        if (status == 'confirmed') ...[
                          const SizedBox(height: 10),
                          SizedBox(width: double.infinity, child: OutlinedButton.icon(
                            onPressed: () => _markComplete(b['_id']),
                            icon: const Icon(Icons.done_all, size: 16),
                            label: const Text('Mark as Collected', style: TextStyle(fontSize: 13)),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                          )),
                        ],
                      ])),
                    );
                  },
                ),
        );
}
