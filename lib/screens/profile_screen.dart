import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _editing = false;
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  int _familySize = 1;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getProfile();
      if (res['success'] == true && mounted) {
        setState(() {
          _user = res['user'];
          _nameCtrl.text = _user?['name'] ?? '';
          _addressCtrl.text = _user?['address'] ?? '';
          _familySize = _user?['familySize'] ?? 1;
          _loading = false;
        });
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _save() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final res = await ApiService.updateProfile({'name': _nameCtrl.text.trim(), 'address': _addressCtrl.text.trim(), 'familySize': _familySize});
      if (!mounted) return;
      Navigator.pop(context);
      if (res['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameCtrl.text.trim());
        setState(() { _user = res['user']; _editing = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Update failed'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _addressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_editing) IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _editing = true))
          else IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _editing = false)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Avatar
                CircleAvatar(radius: 48, backgroundColor: const Color(0xFF2E7D32),
                  child: Text((_user?['name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(height: 16),
                Text(_user?['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('+91-${_user?['phone'] ?? ''}', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 24),

                if (!_editing) ...[
                  _InfoRow(Icons.credit_card, 'Ration Card', _user?['rationCardNumber'] ?? '-'),
                  _InfoRow(Icons.category, 'Category', _user?['category'] ?? '-'),
                  _InfoRow(Icons.people, 'Family Size', '${_user?['familySize'] ?? 1} member(s)'),
                  _InfoRow(Icons.home, 'Address', _user?['address']?.isNotEmpty == true ? _user!['address'] : 'Not set'),
                ] else ...[
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 16),
                  TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home)), maxLines: 2),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Text('Family Size:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { if (_familySize > 1) setState(() => _familySize--); }),
                    Text('$_familySize', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () { if (_familySize < 10) setState(() => _familySize++); }),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Save Changes', style: TextStyle(fontSize: 16)))),
                ],
              ]),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF2E7D32), size: 20),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ]),
    ]),
  );
}
