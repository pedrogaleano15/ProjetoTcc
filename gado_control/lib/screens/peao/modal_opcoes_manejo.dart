import 'package:flutter/material.dart';
import 'card_vacinacao_screen.dart'; // O import da vacina!
import 'historico_manejo_screen.dart'; // O import do histórico!
import '../forms/form_desmame.dart';
import '../forms/form_inseminacao.dart';
import '../forms/form_morte.dart';

void mostrarMenuManejo(BuildContext context, Map<String, dynamic> animal) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manejo: ${animal['identificacao'] ?? animal['brinco']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // 1. BOTÃO DO HISTÓRICO GERAL
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.brown,
                child: Icon(Icons.history, color: Colors.white),
              ),
              title: const Text(
                'Ver Histórico de Manejo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoricoManejoScreen(animal: animal),
                  ),
                );
              },
            ),

            // 2. BOTÃO DA VACINA (AQUI ESTÁ ELE!)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.vaccines, color: Colors.white),
              ),
              title: const Text('Saúde e Vacinação'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CartaoVacinacaoScreen(animalId: animal['id']),
                  ),
                );
              },
            ),

            // 3. BOTÃO DO DESMAME
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.child_care, color: Colors.white),
              ),
              title: const Text('Registar Desmame'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormDesmameScreen(animal: animal),
                  ),
                );
              },
            ),

            // 4. BOTÃO DA INSEMINAÇÃO
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.pink,
                child: Icon(Icons.favorite, color: Colors.white),
              ),
              title: const Text('Registar Inseminação'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormInseminacaoScreen(animal: animal),
                  ),
                );
              },
            ),

            // 5. BOTÃO DE MORTE (BAIXA)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.warning, color: Colors.white),
              ),
              title: const Text('Registar Morte'),
              onTap: () {
                Navigator.pop(context);
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
      );
    },
  );
}
