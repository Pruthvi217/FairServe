import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> getAdminHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('adminToken');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> registerOrLogin({
    required String phone,
    String? name,
    String? rationCardNumber,
    String? firebaseUid,
  }) async {
    final body = <String, dynamic>{'phone': phone};
    if (name != null) body['name'] = name;
    if (rationCardNumber != null) body['rationCardNumber'] = rationCardNumber;
    if (firebaseUid != null) body['firebaseUid'] = firebaseUid;
    final res = await http.post(
      Uri.parse('$baseUrl/register-or-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  // ── PROFILE ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(Uri.parse('$baseUrl/profile'), headers: await getHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ── SHOPS ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getShops({double? lat, double? lng}) async {
    String url = '$baseUrl/shops';
    if (lat != null && lng != null) url += '?lat=$lat&lng=$lng&radius=15000';
    final res = await http.get(Uri.parse(url), headers: await getHeaders());
    return jsonDecode(res.body);
  }

  // ── SLOTS ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSlots({String? shopId, String? date}) async {
    final params = <String, String>{};
    if (shopId != null) params['shopId'] = shopId;
    if (date != null) params['date'] = date;
    final uri = Uri.parse('$baseUrl/slots').replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri, headers: await getHeaders());
    return jsonDecode(res.body);
  }

  // ── BOOKINGS ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> bookSlot(String slotId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/book-slot'),
      headers: await getHeaders(),
      body: jsonEncode({'slotId': slotId}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getMyBookings() async {
    final res = await http.get(Uri.parse('$baseUrl/my-bookings'), headers: await getHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/cancel-booking/$bookingId'),
      headers: await getHeaders(),
    );
    return jsonDecode(res.body);
  }

  // ── RATION / QUOTA ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getQuota() async {
    final res = await http.get(Uri.parse('$baseUrl/quota'), headers: await getHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getRationHistory() async {
    final res = await http.get(Uri.parse('$baseUrl/history'), headers: await getHeaders());
    return jsonDecode(res.body);
  }

  // ── ADMIN ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/stats'), headers: await getAdminHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getAdminShops() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/shops'), headers: await getAdminHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createShop(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/create-shop'),
      headers: await getAdminHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateStock(String shopId, Map<String, dynamic> stock) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/admin/update-stock/$shopId'),
      headers: await getAdminHeaders(),
      body: jsonEncode({'stock': stock}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getAdminSlots() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/slots'), headers: await getAdminHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createSlot(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/create-slot'),
      headers: await getAdminHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getAdminUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/users'), headers: await getAdminHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getAdminBookings() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/bookings'), headers: await getAdminHeaders());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> completeBooking(String bookingId) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/admin/complete-booking/$bookingId'),
      headers: await getAdminHeaders(),
    );
    return jsonDecode(res.body);
  }
}
