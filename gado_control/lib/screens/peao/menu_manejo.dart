import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../forms/form_animal.dart';
import 'peao_scanner_screen.dart';
import 'perfil_animal_screen.dart';
import 'relatorio_vacinacao_screen.dart';
import 'configurar_cronograma_screen.dart'; // Importa a tela interativa!

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

  // Função que pede a observação e abre o PDF do Rebanho
  void _gerarRelatorioRebanho() {
    TextEditingController _obsRebanhoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Observação Geral (Opcional)'),
        content: TextField(
          controller: _obsRebanhoController,
          decoration: const InputDecoration(
            hintText: 'Anotações para o rodapé do PDF...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha a caixa de texto
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RelatorioVacinacaoScreen(
                    observacoesGerais: _obsRebanhoController.text,
                  ),
                ),
              );
            },
            child: const Text('Gerar PDF'),
          ),
        ],
      ),
    );
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
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                // 1. NOVO BOI
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Novo',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
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

                // 2. LER QR CODE
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Scanner',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
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

                // 3. RELATÓRIO DO REBANHO
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Rebanho',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                  ),
                  onPressed: _gerarRelatorioRebanho,
                ),

                // 4. CRONOGRAMA INTERATIVO (O BOTÃO QUE TINHA SUMIDO!)
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Cronograma',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ConfigurarCronogramaScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // LISTA DE ANIMAIS
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _animais.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum animal registado ainda no curral.',
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
