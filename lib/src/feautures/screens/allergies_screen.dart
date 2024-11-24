import 'package:flutter/material.dart';
import 'package:my_vaccine/src/core/services/AllergyService.dart';

class AllergiesScreen extends StatefulWidget {
  @override
  _AllergiesScreenState createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  final AllergyService _allergyService = AllergyService();
  List<dynamic> _allergies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    setState(() => _isLoading = true);
    
    final result = await _allergyService.getAllergies();
    
    if (result['sessionExpired'] == true) {
      Navigator.of(context).pushReplacementNamed('/login'); 
      return;
    }

    setState(() {
      _allergies = result['data'] ?? [];
      _isLoading = false;
    });

    if (result['message'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> _showAddAllergyDialog() async {
    final TextEditingController _nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Alergia'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(hintText: "Nombre de la alergia"),
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Guardar'),
            onPressed: () async {
              if (_nameController.text.isEmpty) return;
              
              final result = await _allergyService.createAllergy(_nameController.text);
              
              Navigator.pop(context);
              
              if (result['sessionExpired'] == true) {
                Navigator.of(context).pushReplacementNamed('/login');
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'])),
              );

              if (result['success']) {
                _loadAllergies(); 
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Alergias'),
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
            : ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _allergies.length,
                itemBuilder: (context, index) {
                  final allergy = _allergies[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.warning, color: Colors.white),
                      ),
                      title: Text(allergy['name']),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAllergyDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}