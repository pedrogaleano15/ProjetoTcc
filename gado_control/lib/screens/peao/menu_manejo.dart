import 'package:flutter/material.dart';
import '../forms/form_desmame.dart';
import '../forms/form_inseminacao.dart';
import '../forms/form_morte.dart';

class MenuManejoScreen extends StatelessWidget {
  // A tela recebe os dados do animal que foi lido no QR Code
  final Map<String, dynamic> animal;

  MenuManejoScreen({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manejo: ${animal['identificacao']}"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumo do Animal no topo
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Animal Selecionado",
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Brinco: ${animal['identificacao']} | Raça: ${animal['raca']}",
                    ),
                    Text("Sexo: ${animal['sexo']}"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            Text(
              "Selecione a operação:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Botão 1: Desmame
            ElevatedButton.icon(
              icon: Icon(Icons.grass),
              label: Text("Registrar Desmame", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.lightGreen[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Navega para o formulário de desmame enviando o animal atual
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormDesmameScreen(animal: animal),
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // Botão 2: Inseminação
            ElevatedButton.icon(
              icon: Icon(Icons.science),
              label: Text(
                "Registrar Inseminação",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Navega para o formulário de inseminação enviando o animal atual
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormInseminacaoScreen(animal: animal),
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // Botão 3: Morte
            ElevatedButton.icon(
              icon: Icon(Icons.warning_amber_rounded),
              label: Text("Registrar Morte", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormMorteScreen(animal: animal),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
