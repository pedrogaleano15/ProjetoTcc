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
  bool _isLoading = true;
  List<Map<String, dynamic>> _listaVacinas = [];
  List<Map<String, dynamic>> _listaDesmames = [];
  List<Map<String, dynamic>> _listaInseminacoes = [];
  List<Map<String, dynamic>> _listaMortes = [];
  List<Map<String, dynamic>> _listaPesagens = [];
  List<Map<String, dynamic>> _listaSaude = [];

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() => _isLoading = true);

    final String animalId = widget.animal['identificacao'].toString();

    // Chamadas sincronizadas com o novo DBHelper (CORRIGE A IMAGEM 2)
    final vacinas = await DatabaseHelper.instance.listarVacinasPorAnimal(
      animalId,
    );
    final desmames = await DatabaseHelper.instance.listarDesmame(animalId);
    final inseminacoes = await DatabaseHelper.instance.listarReproducao(
      animalId,
    );
    final mortes = await DatabaseHelper.instance.listarBaixas(animalId);
    final pesagens = await DatabaseHelper.instance.listarPesagens(animalId);
    final saude = await DatabaseHelper.instance.listarHistoricoSaude(animalId);

    setState(() {
      _listaVacinas = vacinas;
      _listaDesmames = desmames;
      _listaInseminacoes = inseminacoes;
      _listaMortes = mortes;
      _listaPesagens = pesagens;
      _listaSaude = saude;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico: ${widget.animal['identificacao']}'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSecao('Pesagens', _listaPesagens, Icons.scale),
                _buildSecao(
                  'Saúde/Doenças',
                  _listaSaude,
                  Icons.medical_services,
                ),
                _buildSecao('Vacinas', _listaVacinas, Icons.vaccines),
                _buildSecao('Reprodução', _listaInseminacoes, Icons.favorite),
                _buildSecao('Desmame', _listaDesmames, Icons.grass),
                _buildSecao('Baixas', _listaMortes, Icons.warning),
              ],
            ),
    );
  }

  Widget _buildSecao(String titulo, List<Map> lista, IconData icone) {
    if (lista.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icone, color: Colors.green[800]),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...lista
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(
                    item.values.elementAt(2).toString(),
                  ), // Pega um valor genérico para exibição
                  subtitle: Text('Data: ${item.values.elementAt(1)}'),
                ),
              ),
            )
            .toList(),
        const Divider(),
      ],
    );
  }
}
