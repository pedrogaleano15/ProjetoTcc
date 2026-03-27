import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormMorteScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  FormMorteScreen({required this.animal});

  @override
  _FormMorteScreenState createState() => _FormMorteScreenState();
}

class _FormMorteScreenState extends State<FormMorteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _localController = TextEditingController();
  final _causaController = TextEditingController();
  final _idadeController = TextEditingController();

  void _guardarMorte() async {
    if (_formKey.currentState!.validate()) {
      final dadosMorte = {
        'animal_id': widget.animal['id'],
        'data_morte': _dataController.text,
        'local': _localController.text,
        'causa': _causaController.text,
        'idade_meses': int.tryParse(_idadeController.text) ?? 0,
      };

      await DatabaseHelper.instance.inserirMorte(dadosMorte);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registo de baixa de ${widget.animal['identificacao'] ?? widget.animal['brinco']} salvo.',
          ),
          backgroundColor: Colors.red[800],
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
          "Registo de Baixa: ${widget.animal['identificacao'] ?? widget.animal['brinco']}",
        ),
        backgroundColor: Colors.red[800],
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
                color: Colors.red[50],
                child: Text(
                  "Atenção: A registar o óbito do animal ${widget.animal['identificacao'] ?? widget.animal['brinco']} (${widget.animal['raca'] ?? '-'}, ${widget.animal['sexo'] ?? '-'}).",
                  style: TextStyle(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // NOVO CAMPO DE DATA E HORA INTERATIVO
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora da Morte',
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
                controller: _localController,
                decoration: const InputDecoration(
                  labelText: 'Local (Ex: Pasto 4)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _causaController,
                decoration: const InputDecoration(
                  labelText: 'Causa (Ex: Natural, Doença)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(
                  labelText: 'Idade aproximada (em meses)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timelapse),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _guardarMorte,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Guardar Registo",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
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
