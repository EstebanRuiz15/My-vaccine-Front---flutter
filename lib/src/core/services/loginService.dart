import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class loginService {

   final _storage = FlutterSecureStorage();

   Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.68:8080/api/Auth/Login'), 
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['token'] != null) {
        await _storage.write(key: 'token', value: responseBody['token']);
      }

       if (response.statusCode == 401) {
        return responseBody;
      }

      return responseBody;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final token = await _storage.read(key: 'token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No se encontró token de sesión',
          'sessionExpired': true
        };
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.68:8080/api/User/info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesión expirada',
          'sessionExpired': true
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Servicio no disponible'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }
}