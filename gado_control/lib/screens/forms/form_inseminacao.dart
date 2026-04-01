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
    // REGRA DE NEGÓCIO: TRAVA CONTRA MACHOS
    if (widget.animal['sexo'] == 'Macho') {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Ação Bloqueada"),
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, color: Colors.red, size: 80),
              const SizedBox(height: 16),
              const Text(
                "Operação Inválida!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "O sistema de gestão impede o registo de inseminação artificial ou natural em animais do sexo masculino.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Voltar"),
              ),
            ],
          ),
        ),
      );
    }

    // Se for Fêmea, carrega o formulário normal abaixo:
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
                  "A registar inseminação para a fêmea da raça ${widget.animal['raca'] ?? '-'}",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora',
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
                controller: _loteController,
                decoration: const InputDecoration(
                  labelText: 'Lote do Sêmen',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso no Momento (kg)',
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _condicaoController,
                decoration: const InputDecoration(
                  labelText: 'Condição Corporal (1 a 5)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                ),
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
