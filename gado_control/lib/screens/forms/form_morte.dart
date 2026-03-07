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

  // Controladores para capturar os dados
  final _dataController = TextEditingController();
  final _localController = TextEditingController();
  final _causaController = TextEditingController();
  final _idadeController = TextEditingController(); // Idade em meses

  void _guardarMorte() async {
    if (_formKey.currentState!.validate()) {
      // Prepara os dados no formato para o SQLite
      final dadosMorte = {
        'animal_id': widget.animal['id'],
        'data_morte': _dataController.text,
        'local': _localController.text,
        'causa': _causaController.text,
        'idade_meses': int.tryParse(_idadeController.text) ?? 0,
      };

      // Chama a função de inserir no banco de dados
      await DatabaseHelper.instance.inserirMorte(dadosMorte);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registo de baixa (Morte) de ${widget.animal['identificacao']} salvo com sucesso.',
          ),
          backgroundColor: Colors.red[800],
        ),
      );

      // Fecha o formulário
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registo de Baixa: ${widget.animal['identificacao']}"),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Aviso visual
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.red[50],
                child: Text(
                  "Atenção: A registar o óbito do animal ${widget.animal['identificacao']} (${widget.animal['raca']}, ${widget.animal['sexo']}).",
                  style: TextStyle(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: 'Data da Morte (DD/MM/AAAA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _localController,
                decoration: InputDecoration(
                  labelText: 'Local (Ex: Pasto 4, Curral)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _causaController,
                decoration: InputDecoration(
                  labelText: 'Causa (Ex: Natural, Doença, Predador)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _idadeController,
                decoration: InputDecoration(
                  labelText: 'Idade aproximada (em meses)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timelapse),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _guardarMorte,
                icon: Icon(Icons.save),
                label: Padding(
                  padding: const EdgeInsets.all(16.0),
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
