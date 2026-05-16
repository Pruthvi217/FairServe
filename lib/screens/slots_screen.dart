import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});
  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  List<dynamic> _slots = [];
  List<dynamic> _shops = [];
  String? _selectedShopId;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final shopsRes = await ApiService.getShops();
      final slotsRes = await ApiService.getSlots(shopId: _selectedShopId, date: _selectedDate);
      if (mounted) {
        setState(() {
        _shops = shopsRes['success'] == true ? shopsRes['shops'] : [];
        _slots = slotsRes['success'] == true ? slotsRes['slots'] : [];
        _loading = false;
      });
      }
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _bookSlot(String slotId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final res = await ApiService.bookSlot(slotId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? (res['success'] == true ? 'Booked!' : 'Failed')),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ));
      if (res['success'] == true) _load();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
    if (picked != null) { setState(() => _selectedDate = DateFormat('yyyy-MM-dd').format(picked)); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Slots')),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFFE8F5E9),
          child: Column(children: [
            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFA5D6A7))),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF2E7D32), size: 18),
                  const SizedBox(width: 10),
                  Text(DateFormat('dd MMM yyyy').format(DateTime.parse(_selectedDate)), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            // Shop filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFA5D6A7))),
              child: DropdownButton<String?>(
                value: _selectedShopId, isExpanded: true, underline: const SizedBox(),
                hint: const Text('All Shops'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Shops')),
                  ..._shops.map((s) => DropdownMenuItem(value: s['_id'], child: Text(s['name'], overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) { setState(() => _selectedShopId = v); _load(); },
              ),
            ),
          ]),
        ),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _slots.isEmpty
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calendar_month, size: 64, color: Colors.grey), SizedBox(height: 12), Text('No slots available', style: TextStyle(color: Colors.grey))]))
            : ListView.builder(padding: const EdgeInsets.all(12), itemCount: _slots.length, itemBuilder: (_, i) => _SlotCard(slot: _slots[i], onBook: () => _bookSlot(_slots[i]['_id']))),
        ),
      ]),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final Map<String, dynamic> slot; final VoidCallback onBook;
  const _SlotCard({required this.slot, required this.onBook});
  @override
  Widget build(BuildContext context) {
    final isFull = slot['isFull'] == true;
    final isBooked = slot['isBooked'] == true;
    final available = slot['availableSeats'] ?? 0;
    final capacity = slot['capacity'] ?? 30;
    final booked = slot['bookedCount'] ?? 0;
    final fillRatio = booked / capacity;
    Color statusColor = isFull ? Colors.red : (fillRatio > 0.7 ? Colors.orange : Colors.green);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.access_time, color: Color(0xFF2E7D32), size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(slot['shopName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('${slot['date']}  •  ${slot['time']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ])),
          if (isBooked)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)), child: const Text('Booked', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)))
          else if (isFull)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)), child: const Text('Full', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)))
          else
            ElevatedButton(onPressed: onBook, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero), child: const Text('Book', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text('$booked/$capacity seats', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Spacer(),
          Text('$available left', style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: fillRatio.clamp(0.0, 1.0), backgroundColor: Colors.grey.shade200, color: statusColor, minHeight: 6)),
      ])),
    );
  }
}
