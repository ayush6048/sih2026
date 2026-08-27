import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserToken;
  String? _currentUserMobile;
  String? _currentUserName;

  String? get currentUserToken => _currentUserToken;
  String? get currentUserMobile => _currentUserMobile;
  String? get currentUserName => _currentUserName;
  bool get isLoggedIn => _currentUserToken != null;

  void setUserName(String name) {
    _currentUserName = name;
  }

  Future<bool> sendOtp(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile_number': mobileNumber}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile_number': mobileNumber, 'otp': otp}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUserToken = data['token'];
        _currentUserMobile = data['user']['mobile_number'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUserToken = null;
    _currentUserMobile = null;
    _currentUserName = null;
  }
}
