import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RationScreen extends StatefulWidget {
  const RationScreen({super.key});
  @override
  State<RationScreen> createState() => _RationScreenState();
}

class _RationScreenState extends State<RationScreen> {
  Map<String, dynamic>? _quotaData;
  List<dynamic> _history = [];
  bool _loading = true;

  final Map<String, Map<String, dynamic>> _itemMeta = {
    'rice':     {'icon': '🌾', 'color': const Color(0xFFFF8F00), 'unit': 'kg'},
    'wheat':    {'icon': '🌽', 'color': const Color(0xFF6D4C41), 'unit': 'kg'},
    'sugar':    {'icon': '🍚', 'color': const Color(0xFF00ACC1), 'unit': 'kg'},
    'kerosene': {'icon': '🛢️',  'color': const Color(0xFF546E7A), 'unit': 'L'},
    'pulses':   {'icon': '🫘', 'color': const Color(0xFF558B2F), 'unit': 'kg'},
  };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final q = await ApiService.getQuota();
      final h = await ApiService.getRationHistory();
      if (mounted) {
        setState(() {
        _quotaData = q['success'] == true ? q : null;
        _history = h['success'] == true ? h['history'] : [];
        _loading = false;
      });
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ration'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Category badge
                if (_quotaData != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF388E3C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(children: [
                      const Icon(Icons.card_membership, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Category: ${_quotaData!['category']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Family size: ${_quotaData!['familySize']} member(s)', style: const TextStyle(color: Colors.white70)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  const Text('Monthly Entitlement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...(_quotaData!['quota'] as Map<String, dynamic>? ?? {}).entries.map((e) {
                    final meta = _itemMeta[e.key] ?? {'icon': '📦', 'color': Colors.grey, 'unit': 'kg'};
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: (meta['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(meta['icon'] as String, style: const TextStyle(fontSize: 24))),
                        ),
                        title: Text(e.key[0].toUpperCase() + e.key.substring(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Per month allocation'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: (meta['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('${e.value} ${meta['unit']}', style: TextStyle(color: meta['color'] as Color, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 20),
                const Text('Collection History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14)),
                    child: const Column(children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No history yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      Text('Collect your ration to see history', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ]),
                  )
                else
                  ...(_history.map((b) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                      ),
                      title: Text(b['shopName'] ?? 'Ration Shop', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${b['date']}  •  ${b['time']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                        child: Text(b['status'] ?? '', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ))),
              ]),
            ),
    );
  }
}
