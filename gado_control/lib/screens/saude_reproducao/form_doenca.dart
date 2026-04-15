import 'package:flutter/material.dart';
import '../../repositories/gado_repository.dart';

class FormDoencaScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormDoencaScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _FormDoencaScreenState createState() => _FormDoencaScreenState();
}

class _FormDoencaScreenState extends State<FormDoencaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosticoController = TextEditingController();
  final _sintomasController = TextEditingController();
  final _tratamentoController = TextEditingController();
  DateTime _dataDiagnostico = DateTime.now();
  String _status = 'Em Tratamento';

  void _salvarSaude() async {
    if (!_formKey.currentState!.validate()) return;
    final dados = {
      'animal_id': widget.animal['identificacao'].toString(),
      'data_diagnostico': _dataDiagnostico.toIso8601String(),
      'diagnostico': _diagnosticoController.text,
      'sintomas': _sintomasController.text,
      'tratamento': _tratamentoController.text,
      'status': _status,
    };

    await GadoRepository.instance.inserirSaude(dados);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro clínico guardado!'),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Saúde'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _diagnosticoController,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico / Doença',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sintomasController,
                decoration: const InputDecoration(
                  labelText: 'Sintomas Observados',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tratamentoController,
                decoration: const InputDecoration(
                  labelText: 'Medicamento / Tratamento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status Atual',
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: ['Em Tratamento', 'Curado', 'Em Observação']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                title: Text(
                  "Data: ${_dataDiagnostico.day}/${_dataDiagnostico.month}/${_dataDiagnostico.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: _dataDiagnostico,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (p != null) setState(() => _dataDiagnostico = p);
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _salvarSaude,
                  child: const Text(
                    'SALVAR HISTÓRICO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
