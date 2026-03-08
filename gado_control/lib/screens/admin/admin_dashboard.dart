import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../forms/form_animal.dart';
import 'relatorio_ia_screen.dart'; // Importação do novo ecrã de IA

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _animais = [];

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  void _atualizarLista() async {
    final dados = await DatabaseHelper.instance.listarAnimais();
    setState(() {
      _animais = dados;
    });
  }

  // --- NOVA FUNÇÃO: Compilar dados para a IA ---
  void _prepararDadosParaIA() {
    if (_animais.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Cadastre pelo menos um animal para gerar o relatório.",
          ),
        ),
      );
      return;
    }

    // Transforma a lista do banco de dados num texto legível para o Gemini
    String dadosCompilados = "DADOS DO REBANHO:\n\n";
    for (var animal in _animais) {
      dadosCompilados +=
          "- Brinco: ${animal['identificacao']} | Raça: ${animal['raca']} | Sexo: ${animal['sexo']} | Peso Nasc.: ${animal['peso_nascimento']}kg\n";
    }

    // Navega para o ecrã da IA passando o texto compilado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RelatorioIaScreen(dadosGado: dadosCompilados),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Administrativo"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          // <-- ESTA É A PARTE IMPORTANTE
          IconButton(
            icon: Icon(Icons.auto_awesome),
            tooltip: 'Análise Inteligente',
            onPressed: _prepararDadosParaIA,
          ),
        ],
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
                      child: Text(animal['sexo'].substring(0, 1).toUpperCase()),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () async {
          final recarregar = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormAnimalScreen()),
          );
          if (recarregar == true) {
            _atualizarLista();
          }
        },
      ),
    );
  }
}
