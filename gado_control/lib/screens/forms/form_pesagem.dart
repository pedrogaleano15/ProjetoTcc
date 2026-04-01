import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormPesagemScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormPesagemScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _FormPesagemScreenState createState() => _FormPesagemScreenState();
}

class _FormPesagemScreenState extends State<FormPesagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _pesoController = TextEditingController();

  void _salvarPesagem() async {
    if (_formKey.currentState!.validate()) {
      double pesoAnotado =
          double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0;
      int idAnimal = widget.animal['id'];

      final dadosPesagem = {
        'animal_id': idAnimal,
        'data_pesagem': _dataController.text,
        'peso': pesoAnotado,
      };

      // 1. Salva na linha do tempo (Histórico)
      await DatabaseHelper.instance.inserirPesagem(dadosPesagem);

      // 2. Atualiza a ficha oficial do animal!
      await DatabaseHelper.instance.atualizarPesoAnimal(idAnimal, pesoAnotado);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesagem de $pesoAnotado kg registada!'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pesagem: ${widget.animal['identificacao']}"),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.teal[50],
                child: Text(
                  "Último peso conhecido: ${widget.animal['peso_atual'] ?? widget.animal['peso_nascimento']} kg",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora da Pesagem',
                  prefixIcon: Icon(Icons.edit_calendar),
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
                    TimeOfDay? hora = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (hora != null) {
                      setState(() {
                        String d = data.day.toString().padLeft(2, '0');
                        String m = data.month.toString().padLeft(2, '0');
                        String a = data.year.toString();
                        String h = hora.hour.toString().padLeft(2, '0');
                        String min = hora.minute.toString().padLeft(2, '0');
                        _dataController.text = "$d/$m/$a $h:$min";
                      });
                    }
                  }
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pesoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Novo Peso Atual (kg)',
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _salvarPesagem,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Guardar e Atualizar Perfil",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
