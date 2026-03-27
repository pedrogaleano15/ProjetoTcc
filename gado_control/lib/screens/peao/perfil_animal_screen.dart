import 'package:flutter/material.dart';
import 'modal_opcoes_manejo.dart';

class PerfilAnimalScreen extends StatelessWidget {
  final Map<String, dynamic> animal;

  const PerfilAnimalScreen({Key? key, required this.animal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ficha: ${animal['identificacao'] ?? animal['brinco']}'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações Gerais',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: const Text('Brinco / Identificação'),
                      subtitle: Text(
                        (animal['identificacao'] ?? animal['brinco'])
                            .toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.pets),
                      title: const Text('Raça e Sexo'),
                      subtitle: Text(
                        '${animal['raca'] ?? '-'} | ${animal['sexo'] ?? '-'}',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Data de Nascimento'),
                      subtitle: Text(
                        animal['data_nascimento']?.toString() ??
                            'Não informada',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.assignment, color: Colors.white),
              label: const Text(
                'Opções de Manejo',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                mostrarMenuManejo(context, animal);
              },
            ),
          ],
        ),
      ),
    );
  }
}
