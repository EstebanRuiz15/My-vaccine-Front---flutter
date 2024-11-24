import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_vaccine/src/core/services/VaccineService.dart';

class VaccineRecordsScreen extends StatefulWidget {
  @override
  _VaccineRecordsScreenState createState() => _VaccineRecordsScreenState();
}

class _VaccineRecordsScreenState extends State<VaccineRecordsScreen> {
  final VaccineService _vaccineRecordService = VaccineService();
  List<dynamic> _vaccineRecords = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVaccineRecords();
  }

  Future<void> _loadVaccineRecords() async {
    setState(() => _isLoading = true);
    
    final result = await _vaccineRecordService.getVaccineRecords();
    
    if (result['sessionExpired'] == true) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() {
      _vaccineRecords = result['data'] ?? [];
      _isLoading = false;
    });

    // Solo mostrar mensaje si hay un error
    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Vacunas'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _vaccineRecords.isEmpty
                ? const Center(
                    child: Text(
                      'No hay registros de vacunas',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _vaccineRecords.length,
                    itemBuilder: (context, index) {
                      final record = _vaccineRecords[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.vaccines,
                                      color: Theme.of(context).primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      record['vaccine'] ?? 'Vacuna sin nombre',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              InfoRow(
                                icon: Icons.calendar_today,
                                text: _formatDate(record['dateAdministered']),
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                icon: Icons.location_on,
                                text: record['administeredLocation'] ?? 'Ubicación no especificada',
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                icon: Icons.person,
                                text: record['administeredBy'] ?? 'Aplicador no especificado',
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}