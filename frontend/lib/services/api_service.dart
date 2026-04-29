import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Laravel default

  static Future<Map<String, dynamic>?> startSession(String qrCodeId) async {
    try {
      String tableId = qrCodeId.replaceAll(RegExp(r'[^0-9]'), '');
      if (tableId.isEmpty) tableId = '1';

      final response = await http.post(
        Uri.parse('$baseUrl/session/$tableId'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_token', data['session_token']);
        return data;
      }
    } catch (e) {
      print('Error starting session: $e');
    }
    return null;
  }

  static Future<List<dynamic>> getMenuItems(String? categoryName) async {
    try {
      String url = categoryName != null 
          ? '$baseUrl/menu/category/$categoryName' 
          : '$baseUrl/menu';
          
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'}
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> placeOrder(List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      
      if (sessionToken == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/order'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'session_id': sessionToken,
          'items': items,
        })
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error placing order: $e');
    }
    return null;
  }

  static Future<List<dynamic>> getSessionOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      
      if (sessionToken == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/order/$sessionToken'),
        headers: {'Accept': 'application/json'}
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error tracking orders: $e');
    }
    return [];
  }

  // New Day 3 Endpoints

  static Future<List<dynamic>> getStaffOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/staff/orders'),
        headers: {'Accept': 'application/json'}
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching staff orders: $e');
    }
    return [];
  }

  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/order/$orderId/status'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'status': status})
      );
      
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error updating status: $e');
    }
    return false;
  }

  static Future<List<dynamic>> getRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');
      
      if (sessionToken == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/recommend/$sessionToken'),
        headers: {'Accept': 'application/json'}
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['recommendations'] ?? [];
      }
    } catch (e) {
      print('Error getting recommendations: $e');
    }
    return [];
  }
}
