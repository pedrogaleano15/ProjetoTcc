import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormDesmameScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  FormDesmameScreen({required this.animal});

  @override
  _FormDesmameScreenState createState() => _FormDesmameScreenState();
}

class _FormDesmameScreenState extends State<FormDesmameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _pesoController = TextEditingController();

  void _salvarDesmame() async {
    if (_formKey.currentState!.validate()) {
      final dadosDesmame = {
        'animal_id': widget.animal['id'],
        'data_desmame': _dataController.text,
        'peso_desmame':
            double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0,
      };

      await DatabaseHelper.instance.inserirDesmame(dadosDesmame);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Desmame de ${widget.animal['identificacao'] ?? widget.animal['brinco']} registado!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Desmame: ${widget.animal['identificacao'] ?? widget.animal['brinco']}",
        ),
        backgroundColor: Colors.lightGreen[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[200],
                child: Text(
                  "A registar desmame para o animal da raça ${widget.animal['raca'] ?? '-'} (${widget.animal['sexo'] ?? '-'})",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // NOVO CAMPO DE DATA E HORA INTERATIVO
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora do Desmame',
                  hintText: 'Toque para escolher...',
                  prefixIcon: Icon(Icons.edit_calendar),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? dataEscolhida = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (dataEscolhida != null) {
                    TimeOfDay? horaEscolhida = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (horaEscolhida != null) {
                      setState(() {
                        String dia = dataEscolhida.day.toString().padLeft(
                          2,
                          '0',
                        );
                        String mes = dataEscolhida.month.toString().padLeft(
                          2,
                          '0',
                        );
                        String ano = dataEscolhida.year.toString();
                        String hora = horaEscolhida.hour.toString().padLeft(
                          2,
                          '0',
                        );
                        String minuto = horaEscolhida.minute.toString().padLeft(
                          2,
                          '0',
                        );
                        _dataController.text = "$dia/$mes/$ano $hora:$minuto";
                      });
                    }
                  }
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso no Desmame (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _salvarDesmame,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Salvar Desmame", style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
