import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../forms/form_animal.dart';
import 'peao_scanner_screen.dart';
import 'perfil_animal_screen.dart';

class MenuManejoScreen extends StatefulWidget {
  const MenuManejoScreen({Key? key}) : super(key: key);

  @override
  _MenuManejoScreenState createState() => _MenuManejoScreenState();
}

class _MenuManejoScreenState extends State<MenuManejoScreen> {
  List<Map<String, dynamic>> _animais = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  Future<void> _atualizarLista() async {
    final dados = await DatabaseHelper.instance.listarAnimais();
    setState(() {
      _animais = dados;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manejo do Gado'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.green[50],
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Novo Boi',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormAnimalScreen(),
                        ),
                      );
                      _atualizarLista();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Ler QR',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PeaoScannerScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _animais.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum animal registrado ainda no curral.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _animais.length,
                    itemBuilder: (context, index) {
                      final animal = _animais[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Icon(Icons.pets, color: Colors.green[800]),
                          ),
                          title: Text(
                            'Brinco: ${animal['identificacao'] ?? animal['brinco']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Raça: ${animal['raca'] ?? '-'} | Sexo: ${animal['sexo'] ?? '-'}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PerfilAnimalScreen(animal: animal),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
