import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormDesmameScreen extends StatefulWidget {
  // Recebe os dados do animal vindo da tela anterior
  final Map<String, dynamic> animal;

  FormDesmameScreen({required this.animal});

  @override
  _FormDesmameScreenState createState() => _FormDesmameScreenState();
}

class _FormDesmameScreenState extends State<FormDesmameScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar os dados
  final _dataController = TextEditingController();
  final _pesoController = TextEditingController();

  void _salvarDesmame() async {
    if (_formKey.currentState!.validate()) {
      // Prepara os dados no formato que o SQLite espera
      final dadosDesmame = {
        'animal_id': widget.animal['id'], // Chave estrangeira!
        'data_desmame': _dataController.text,
        'peso_desmame': double.tryParse(_pesoController.text) ?? 0.0,
      };

      // Chama a função de inserir no banco de dados
      await DatabaseHelper.instance.inserirDesmame(dadosDesmame);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Desmame de ${widget.animal['identificacao']} registado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Fecha o formulário e volta ao menu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Desmame: ${widget.animal['identificacao']}"),
        backgroundColor: Colors.lightGreen[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Aviso visual confirmando o animal
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.grey[200],
                child: Text(
                  "A registar desmame para o animal da raça ${widget.animal['raca']} (${widget.animal['sexo']})",
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              // Campo da Data
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: 'Data do Desmame (DD/MM/AAAA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              // Campo do Peso
              TextFormField(
                controller: _pesoController,
                decoration: InputDecoration(
                  labelText: 'Peso no Desmame (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 30),

              // Botão de Salvar
              ElevatedButton.icon(
                onPressed: _salvarDesmame,
                icon: Icon(Icons.save),
                label: Padding(
                  padding: const EdgeInsets.all(16.0),
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
