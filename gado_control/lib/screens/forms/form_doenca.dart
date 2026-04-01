import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormDoencaScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormDoencaScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _FormDoencaScreenState createState() => _FormDoencaScreenState();
}

class _FormDoencaScreenState extends State<FormDoencaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _tratamentoController = TextEditingController();

  void _salvarDoenca() async {
    if (_formKey.currentState!.validate()) {
      final dadosDoenca = {
        'animal_id': widget.animal['id'],
        'diagnostico': _diagnosticoController.text,
        'data_diagnostico': _dataController.text,
        'tratamento_aplicado': _tratamentoController.text.isEmpty
            ? 'Aguardando tratamento'
            : _tratamentoController.text,
        'status_cura': 'Ativa', // Fica ativa até ser curado na ficha!
      };

      await DatabaseHelper.instance.inserirDoenca(dadosDoenca);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alerta de doença registado! O animal entrou em Quarentena visual.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reportar Doença"),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _diagnosticoController,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico / Sintomas',
                  prefixIcon: Icon(Icons.sick),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data de Identificação',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? data = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) {
                    setState(() {
                      _dataController.text =
                          "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
                    });
                  }
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tratamentoController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Tratamento Inicial (Opcional)',
                  prefixIcon: Icon(Icons.medical_services),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _salvarDoenca,
                icon: const Icon(Icons.warning, color: Colors.white),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Registar e Iniciar Quarentena",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
