import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class HistoricoManejoScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const HistoricoManejoScreen({Key? key, required this.animal})
    : super(key: key);

  @override
  _HistoricoManejoScreenState createState() => _HistoricoManejoScreenState();
}

class _HistoricoManejoScreenState extends State<HistoricoManejoScreen> {
  List<Map<String, dynamic>> _historico = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final animalId = widget.animal['id'];

    // Busca TODOS os eventos no banco de dados, INCLUINDO AS VACINAS!
    final vacinas = await DatabaseHelper.instance.listarVacinasPorAnimal(
      animalId,
    );
    final desmames = await DatabaseHelper.instance.listarDesmamesPorAnimal(
      animalId,
    );
    final inseminacoes = await DatabaseHelper.instance
        .listarInseminacoesPorAnimal(animalId);
    final mortes = await DatabaseHelper.instance.listarMortesPorAnimal(
      animalId,
    );

    List<Map<String, dynamic>> tempLista = [];

    // 1. Adiciona as Vacinas na lista
    for (var v in vacinas) {
      tempLista.add({
        'tipo': 'Vacina',
        'data': v['dataAplicacao'] ?? v['data_aplicacao'] ?? 'Sem data',
        'detalhe': 'Vacina: ${v['nomeVacina'] ?? v['nome_vacina']}',
      });
    }
    // 2. Adiciona os Desmames
    for (var d in desmames) {
      tempLista.add({
        'tipo': 'Desmame',
        'data': d['data_desmame'],
        'detalhe': 'Peso: ${d['peso_desmame']} kg',
      });
    }
    // 3. Adiciona as Inseminações
    for (var i in inseminacoes) {
      tempLista.add({
        'tipo': 'Inseminação',
        'data': i['data_inseminacao'],
        'detalhe': 'Lote: ${i['lote']} | Condição: ${i['condicao_corporal']}',
      });
    }
    // 4. Adiciona a Morte
    for (var m in mortes) {
      tempLista.add({
        'tipo': 'Morte',
        'data': m['data_morte'],
        'detalhe': 'Causa: ${m['causa']} | Local: ${m['local']}',
      });
    }

    setState(() {
      _historico = tempLista;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Histórico: ${widget.animal['identificacao'] ?? widget.animal['brinco']}',
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historico.isEmpty
          ? const Center(
              child: Text('Nenhum maneio registado ainda para este animal.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historico.length,
              itemBuilder: (context, index) {
                final item = _historico[index];

                IconData icone = Icons.check;
                Color cor = Colors.grey;

                if (item['tipo'] == 'Vacina') {
                  icone = Icons.vaccines;
                  cor = Colors.blue;
                } else if (item['tipo'] == 'Desmame') {
                  icone = Icons.child_care;
                  cor = Colors.orange;
                } else if (item['tipo'] == 'Inseminação') {
                  icone = Icons.favorite;
                  cor = Colors.pink;
                } else if (item['tipo'] == 'Morte') {
                  icone = Icons.warning;
                  cor = Colors.black;
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cor,
                      child: Icon(icone, color: Colors.white),
                    ),
                    title: Text(
                      item['tipo'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Data/Hora: ${item['data']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          item['detalhe'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
