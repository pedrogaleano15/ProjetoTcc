import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormInseminacaoScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  FormInseminacaoScreen({required this.animal});

  @override
  _FormInseminacaoScreenState createState() => _FormInseminacaoScreenState();
}

class _FormInseminacaoScreenState extends State<FormInseminacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _loteController = TextEditingController();
  final _pesoController = TextEditingController();
  final _condicaoController = TextEditingController();
  final _categoriaController = TextEditingController();

  void _guardarInseminacao() async {
    if (_formKey.currentState!.validate()) {
      final dadosInseminacao = {
        'animal_id': widget.animal['id'],
        'data_inseminacao': _dataController.text,
        'lote': _loteController.text,
        'peso_momento':
            double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0,
        'condicao_corporal': _condicaoController.text,
        'categoria': _categoriaController.text,
      };

      await DatabaseHelper.instance.inserirInseminacao(dadosInseminacao);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Inseminação de ${widget.animal['identificacao'] ?? widget.animal['brinco']} registada!',
          ),
          backgroundColor: Colors.blue,
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
          "Inseminação: ${widget.animal['identificacao'] ?? widget.animal['brinco']}",
        ),
        backgroundColor: Colors.blue[700],
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
                  "A registar inseminação para o animal da raça ${widget.animal['raca'] ?? '-'}",
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
                  labelText: 'Data e Hora da Inseminação',
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
                controller: _loteController,
                decoration: const InputDecoration(
                  labelText: 'Lote (Ex: Lote A)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso no Momento (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _condicaoController,
                decoration: const InputDecoration(
                  labelText: 'Condição Corporal (1 a 5)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoria (Ex: Novilha)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _guardarInseminacao,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Guardar Inseminação",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
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
