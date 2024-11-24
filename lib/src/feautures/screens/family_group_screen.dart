import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:my_vaccine/src/core/services/GroupFamilyService.dart';

class FamilyGroupScreen extends StatefulWidget {
  @override
  _FamilyGroupScreenState createState() => _FamilyGroupScreenState();
}

class _FamilyGroupScreenState extends State<FamilyGroupScreen> {
  final FamilyGroupService _familyGroupService = FamilyGroupService();
  List<dynamic> _familyGroups = [];
  bool _isLoading = false;
  bool _sessionExpired = false;

  // Listas para generar datos aleatorios
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _relationships = [
    'Padre', 'Madre', 'Hijo/a', 'Abuelo/a', 'Tío/a', 
    'Primo/a', 'Sobrino/a', 'Cónyuge'
  ];

  String getRandomElement(List<String> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }

  @override
  void initState() {
    super.initState();
    _loadFamilyGroup();
  }

  Future<void> _loadFamilyGroup() async {
    setState(() => _isLoading = true);
    final result = await _familyGroupService.getFamilyGroup();

    if (result['sessionExpired'] == true) {
      setState(() {
        _sessionExpired = true;
      });
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() {
      _familyGroups = result['data'] ?? [];
      _isLoading = false;
    });

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupo Familiar'),
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
            ? const Center(child: CircularProgressIndicator())
            : _familyGroups.isEmpty
                ? const Center(
                    child: Text(
                      'No hay grupos familiares',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _familyGroups.length,
                    itemBuilder: (context, index) {
                      final group = _familyGroups[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título del grupo familiar
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            child: Center(
                              child: Text(
                                group['name'],
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 1),
                                      blurRadius: 3.0,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Grid de miembros familiares
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.70,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: group['users'].length,
                            itemBuilder: (context, userIndex) {
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        child: Text(
                                          group['users'][userIndex][0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        group['users'][userIndex],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tipo de sangre: ${getRandomElement(_bloodTypes)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        getRandomElement(_relationships),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar la funcionalidad de agregar
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}