import 'dart:convert';
import 'dart:io' show InternetAddress, Platform, SocketException;
import 'package:http/http.dart' as http;

class ServiceRegister {
  // Tu IP actual
  final String _baseUrl = 'http://192.168.1.68:8080'; 

 Future<Map<String, dynamic>> registerUser(
    String name, String lastName, String email, String password) async {
  final url = Uri.parse('$_baseUrl/api/Auth/register');

  try {
    testConnection(url.toString());
    print('Intentando registro en: $url');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'Email': email,
        'Password': password,
        'FirstName': name,
        'LastName': lastName
      }),
    ).timeout(Duration(seconds: 10));

    print('Código de respuesta: ${response.statusCode}');
    print('Cuerpo de respuesta: ${response.body}');

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Registro exitoso'};
    } else {
      return {
        'success': false, 
        'message': 'Error ${response.statusCode}: ${response.body}'
      };
    }
  } catch (e) {
    print('Error de conexión: $e');
    return {
      'success': false, 
      'message': 'Error de conexión: $e'
    };
  }
}

Future<bool> testConnection(String url) async {
  try {
    final response = await http.get(Uri.parse('$url/ping'))
        .timeout(Duration(seconds: 5));
    print(response);
    return response.statusCode == 200;
    
  } catch (e) {
    print('Error de conexión a $url: $e');
    return false;
  }
}
}