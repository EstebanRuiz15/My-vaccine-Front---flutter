import 'package:flutter/material.dart';
import 'package:my_vaccine/src/core/services/VaccineService.dart';

class NewVaccineScreen extends StatefulWidget {
  @override
  _NewVaccineScreenState createState() => _NewVaccineScreenState();
}

class _NewVaccineScreenState extends State<NewVaccineScreen> {
  final VaccineService _vaccineService = VaccineService();
  final _formKey = GlobalKey<FormState>();
  
  List<Map<String, dynamic>> _availableVaccines = [];
  bool _isLoading = true;
  int? _selectedVaccineId;
  final _locationController = TextEditingController();
  final _administeredByController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _administeredByController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccines() async {
    final result = await _vaccineService.getAvailableVaccines();
    
    if (result['sessionExpired'] == true) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() {
      _availableVaccines = List<Map<String, dynamic>>.from(result['data'] ?? []);
      _isLoading = false;
    });
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('¡Éxito!'),
          ],
        ),
        content: Text('La vacuna ha sido registrada exitosamente.'),
        actions: [
          ElevatedButton(
            child: Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Regresa a la pantalla anterior
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _vaccineService.registerVaccine(
      vaccineId: _selectedVaccineId!,
      administeredLocation: _locationController.text,
      administeredBy: _administeredByController.text,
    );

    setState(() => _isLoading = false);

    if (result['sessionExpired'] == true) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    if (result['success']) {
      await _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Vacuna'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedVaccineId,
                            decoration: InputDecoration(
                              labelText: 'Seleccionar Vacuna',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.vaccines),
                            ),
                            items: _availableVaccines.map((vaccine) {
                              // Convertimos explícitamente el id a int
                              return DropdownMenuItem<int>(
                                value: int.parse(vaccine['id'].toString()),
                                child: Text(vaccine['name'].toString()),
                              );
                            }).toList(),
                            validator: (value) => value == null 
                                ? 'Por favor seleccione una vacuna' 
                                : null,
                            onChanged: (value) {
                              setState(() => _selectedVaccineId = value);
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Lugar de Administración',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Este campo es requerido'
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _administeredByController,
                            decoration: InputDecoration(
                              labelText: 'Administrado por',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Este campo es requerido'
                                : null,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: Icon(Icons.save),
                            label: Text('Registrar Vacuna'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}