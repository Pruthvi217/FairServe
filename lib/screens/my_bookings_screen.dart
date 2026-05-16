import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getMyBookings();
      if (mounted) {
        setState(() {
        _bookings = res['success'] == true ? res['bookings'] : [];
        _loading = false;
      });
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _cancel(String bookingId) async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Cancel Booking'),
      content: const Text('Are you sure you want to cancel this booking?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Yes, Cancel')),
      ],
    ));
    if (confirm != true) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final res = await ApiService.cancelBooking(bookingId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Done'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ));
      if (res['success'] == true) _load();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmed': return Icons.check_circle;
      case 'completed': return Icons.done_all;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bookmark_border, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No bookings yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Book a slot from the Slots tab', style: TextStyle(color: Colors.grey)),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (_, i) {
                      final b = _bookings[i];
                      final status = b['status'] ?? 'confirmed';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.storefront, color: Color(0xFF2E7D32)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(b['shopName'] ?? 'Ration Shop', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text('${b['date']}  •  ${b['time']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(_statusIcon(status), size: 14, color: _statusColor(status)),
                                  const SizedBox(width: 4),
                                  Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w600, fontSize: 12)),
                                ]),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(children: [
                              _InfoChip(Icons.confirmation_number, 'Token #${b['tokenNumber'] ?? '-'}'),
                              const Spacer(),
                              if (status == 'confirmed')
                                OutlinedButton.icon(
                                  onPressed: () => _cancel(b['_id']),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Cancel', style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                ),
                            ]),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label;
  const _InfoChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 15, color: Colors.grey.shade600),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
  ]);
}
