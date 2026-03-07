import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../forms/form_animal.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _animais = [];

  @override
  void initState() {
    super.initState();
    _atualizarLista(); // Carrega os dados quando a tela abre
  }

  // Busca os animais no SQLite
  void _atualizarLista() async {
    final dados = await DatabaseHelper.instance.listarAnimais();
    setState(() {
      _animais = dados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Administrativo"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: _animais.isEmpty
          ? Center(
              child: Text(
                "Nenhum animal cadastrado ainda.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _animais.length,
              itemBuilder: (context, index) {
                final animal = _animais[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        animal['sexo'].substring(0, 1).toUpperCase(),
                      ), // M ou F
                    ),
                    title: Text(
                      "Brinco: ${animal['identificacao']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Raça: ${animal['raca']} | Peso: ${animal['peso_nascimento']}kg",
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
      // Botão flutuante para adicionar novo animal
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () async {
          // Navega para o formulário e espera ele fechar
          final recarregar = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormAnimalScreen()),
          );
          // Se o formulário avisar que salvou algo (true), recarrega a lista
          if (recarregar == true) {
            _atualizarLista();
          }
        },
      ),
    );
  }
}
