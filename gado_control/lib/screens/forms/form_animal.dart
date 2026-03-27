import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../models/animal.dart';

class FormAnimalScreen extends StatefulWidget {
  @override
  _FormAnimalScreenState createState() => _FormAnimalScreenState();
}

class _FormAnimalScreenState extends State<FormAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  String? _sexoSelecionado;
  final List<String> _opcoesSexo = ['Macho', 'Fêmea'];
  final _racaController = TextEditingController();
  final _maeController = TextEditingController();
  final _dataController = TextEditingController();
  final _pesoController = TextEditingController();

  void _salvarAnimal() async {
    if (_formKey.currentState!.validate()) {
      final novoAnimal = Animal(
        identificacao: _idController.text,
        sexo: _sexoSelecionado!,
        raca: _racaController.text,
        maeIdentificacao: _maeController.text,
        dataNascimento: _dataController.text,
        pesoNascimento: double.parse(_pesoController.text.replaceAll(',', '.')),
      );

      await DatabaseHelper.instance.inserirAnimal(novoAnimal.toMap());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Animal ${_idController.text} salvo com sucesso!'),
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
        title: const Text("Cadastrar Novo Animal"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Identificação (Nº Brinco/QR Code)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _racaController,
                decoration: const InputDecoration(
                  labelText: 'Raça (Ex: Nelore)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _sexoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  prefixIcon: Icon(Icons.transgender),
                  border: OutlineInputBorder(),
                ),
                items: _opcoesSexo.map((String sexo) {
                  return DropdownMenuItem<String>(
                    value: sexo,
                    child: Text(sexo),
                  );
                }).toList(),
                onChanged: (String? novoValor) {
                  setState(() {
                    _sexoSelecionado = novoValor;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, selecione o sexo'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso ao Nascer (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 10),

              // NOVO CAMPO DE DATA E HORA INTERATIVO
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora de Nascimento',
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
              const SizedBox(height: 10),
              TextFormField(
                controller: _maeController,
                decoration: const InputDecoration(
                  labelText: 'Identificação da Mãe (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarAnimal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Salvar Animal", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
