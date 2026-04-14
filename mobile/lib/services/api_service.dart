import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://mollusklike-intactly-kennedi.ngrok-free.dev';

  // Auth endpoints
  static const String loginEndpoint = '/api/mobile/login';
  static const String registerEndpoint = '/api/mobile/register';
  static const String logoutEndpoint = '/api/mobile/logout';

  // Patient endpoints
  static const String patientDashboard = '/api/mobile/patient/dashboard';
  static const String patientDoctors = '/api/mobile/patient/doctors';
  static const String patientSpecializations = '/api/mobile/patient/specializations';
  static const String patientBooking = '/api/mobile/patient/booking';
  static const String patientMedicalRecords = '/api/mobile/patient/medical-records';
  static const String patientNotifications = '/api/mobile/patient/notifications';
  static const String patientProfile = '/api/mobile/patient/profile';
  static const String patientPayment = '/api/mobile/patient/payment';

  // Doctor endpoints
  static const String doctorBooking = '/api/mobile/doctor/booking';

  // Headers - TAMBAHKAN ngrok-skip-browser-warning
  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', // <-- INI PENTING!
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    debugPrint('🔑 Token saved: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      debugPrint('🔑 Token retrieved: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    } else {
      debugPrint('⚠️ No token found');
    }
    return token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    debugPrint('🗑️ Token cleared');
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$endpoint');

    debugPrint('📤 POST: $uri');
    debugPrint('📤 Headers: ${_getHeaders(token)}');
    debugPrint('📤 Body: $data');

    final response = await http.post(
      uri,
      headers: _getHeaders(token),
      body: jsonEncode(data),
    );

    debugPrint('📥 Response (${response.statusCode}): ${response.body}');
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    final token = await getToken();
    Uri uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    debugPrint('📤 GET: $uri');
    debugPrint('📤 Headers: ${_getHeaders(token)}');

    final response = await http.get(
      uri,
      headers: _getHeaders(token),
    );

    debugPrint('📥 Response (${response.statusCode}): ${response.body}');
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$endpoint');

    debugPrint('📤 PUT: $uri');
    debugPrint('📤 Headers: ${_getHeaders(token)}');
    debugPrint('📤 Body: $data');

    final response = await http.put(
      uri,
      headers: _getHeaders(token),
      body: jsonEncode(data),
    );

    debugPrint('📥 Response (${response.statusCode}): ${response.body}');
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$endpoint');

    debugPrint('📤 DELETE: $uri');
    debugPrint('📤 Headers: ${_getHeaders(token)}');

    final response = await http.delete(
      uri,
      headers: _getHeaders(token),
    );

    debugPrint('📥 Response (${response.statusCode}): ${response.body}');
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      debugPrint('❌ Unauthorized (401) - Token mungkin expired');
      throw Exception('Unauthorized - Please login again');
    } else {
      debugPrint('❌ Server error: ${response.statusCode}');
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}