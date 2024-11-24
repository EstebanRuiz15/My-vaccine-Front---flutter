import 'package:flutter/material.dart';
import 'package:my_vaccine/src/routes/routes.dart';
import 'package:my_vaccine/src/core/services/serviceRegister.dart';
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _isPasswordVisible = false;
  final ServiceRegister _authService = ServiceRegister();
  bool _isLoading = false;

  final List<String> _passwordRequirements = [
    'Al menos 8 caracteres',
    'Al menos una mayúscula',
    'Al menos un número',
  ];

  bool _checkPasswordRequirement(String password, int index) {
    switch (index) {
      case 0:
        return password.length >= 8;
      case 1:
        return password.contains(RegExp(r'[A-Z]'));
      case 2:
        return password.contains(RegExp(r'[0-9]'));
      default:
        return false;
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    return null;
  }
Future<void> _register() async {
  if (_formKey.currentState!.validate() &&
      _passwordRequirements.asMap().entries.every((entry) =>
          _checkPasswordRequirement(_passwordController.text, entry.key))) {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.registerUser(
        _nameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
      );

      print('Respuesta del registro: $response');

      if (response['success']) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('El email ya existe');
      }
    } catch (e) {
      print('Error completo: $e');
      _showErrorDialog('Hubo un problema al registrar el usuario.\nPor favor, intenta nuevamente.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 28,
          ),
          SizedBox(width: 10),
          Text(
            'Éxito',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        'Registrado correctamente. Redirigiendo a la pantalla de inicio de sesión.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
          child: Text(
            'Entendido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 28,
          ),
          SizedBox(width: 10),
          Text(
            'Error',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Entendido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El apellido es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                  errorText: _isEmailValid ? null : 'Email inválido',
                ),
                onChanged: (value) {
                  setState(() {
                    _isEmailValid = _validateEmail(value) == null;
                  });
                },
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _passwordRequirements.asMap().entries.map((entry) {
                  final index = entry.key;
                  final requirement = entry.value;
                  final isValid =
                      _checkPasswordRequirement(_passwordController.text, index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isValid ? Icons.check_circle : Icons.circle_outlined,
                          color: isValid ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          requirement,
                          style: TextStyle(
                            color: isValid ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: _isLoading
                      ? null // Deshabilitar el botón si estamos cargando
                      : _register, // Llamamos al método _register
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator() // Mostrar indicador de carga si estamos esperando respuesta
                      : const Text(
                          'Registrarse',
                          style: TextStyle(fontSize: 16),
                        ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
