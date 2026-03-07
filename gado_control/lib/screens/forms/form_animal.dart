import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../models/animal.dart';

class FormAnimalScreen extends StatefulWidget {
  @override
  _FormAnimalScreenState createState() => _FormAnimalScreenState();
}

class _FormAnimalScreenState extends State<FormAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o que o usuário digita
  final _idController = TextEditingController();
  final _sexoController = TextEditingController();
  final _racaController = TextEditingController();
  final _maeController = TextEditingController();
  final _dataController = TextEditingController();
  final _pesoController = TextEditingController();

  void _salvarAnimal() async {
    if (_formKey.currentState!.validate()) {
      // Cria o objeto Animal com os dados digitados
      final novoAnimal = Animal(
        identificacao: _idController.text,
        sexo: _sexoController.text,
        raca: _racaController.text,
        maeIdentificacao: _maeController.text,
        dataNascimento: _dataController.text,
        pesoNascimento: double.parse(_pesoController.text),
      );

      // Salva no SQLite
      await DatabaseHelper.instance.inserirAnimal(novoAnimal.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Animal ${_idController.text} salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Fecha a tela e avisa que salvou
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Novo Animal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Identificação (Nº Brinco/QR Code)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _racaController,
                decoration: InputDecoration(
                  labelText: 'Raça (Ex: Nelore)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _sexoController,
                decoration: InputDecoration(
                  labelText: 'Sexo (Macho/Fêmea)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _pesoController,
                decoration: InputDecoration(
                  labelText: 'Peso ao Nascer (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento (DD/MM/AAAA)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _maeController,
                decoration: InputDecoration(
                  labelText: 'Identificação da Mãe (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarAnimal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Salvar Animal", style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
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
