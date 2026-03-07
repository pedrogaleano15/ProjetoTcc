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

  // Controladores para capturar os dados do formulário
  final _dataController = TextEditingController();
  final _loteController = TextEditingController();
  final _pesoController = TextEditingController();
  final _condicaoController = TextEditingController();
  final _categoriaController = TextEditingController();

  void _guardarInseminacao() async {
    if (_formKey.currentState!.validate()) {
      // Prepara os dados no formato para o SQLite
      final dadosInseminacao = {
        'animal_id': widget.animal['id'],
        'data_inseminacao': _dataController.text,
        'lote': _loteController.text,
        'peso_momento': double.tryParse(_pesoController.text) ?? 0.0,
        'condicao_corporal': _condicaoController.text,
        'categoria': _categoriaController.text,
      };

      // Chama a função de inserir no banco de dados (que criámos anteriormente)
      await DatabaseHelper.instance.inserirInseminacao(dadosInseminacao);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Inseminação de ${widget.animal['identificacao']} registada com sucesso!',
          ),
          backgroundColor: Colors.blue,
        ),
      );

      Navigator.pop(context); // Fecha o formulário e volta ao menu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inseminação: ${widget.animal['identificacao']}"),
        backgroundColor: Colors.blue[700],
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
                  "A registar inseminação para o animal da raça ${widget.animal['raca']}",
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: 'Data da Inseminação (DD/MM/AAAA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _loteController,
                decoration: InputDecoration(
                  labelText: 'Lote (Ex: Lote A, Lote Inverno)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _pesoController,
                decoration: InputDecoration(
                  labelText: 'Peso no Momento (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _condicaoController,
                decoration: InputDecoration(
                  labelText: 'Condição Corporal (Ex: Escore 1 a 5)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(
                  labelText: 'Categoria (Ex: Novilha, Vaca Parida)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _guardarInseminacao,
                icon: Icon(Icons.save),
                label: Padding(
                  padding: const EdgeInsets.all(16.0),
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
