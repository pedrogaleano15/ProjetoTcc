import 'package:flutter/material.dart';
import '../../repositories/gado_repository.dart';

class HistoricoMovimentacoesScreen extends StatefulWidget {
  const HistoricoMovimentacoesScreen({Key? key}) : super(key: key);

  @override
  _HistoricoMovimentacoesScreenState createState() =>
      _HistoricoMovimentacoesScreenState();
}

class _HistoricoMovimentacoesScreenState
    extends State<HistoricoMovimentacoesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _movimentacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final dados = await GadoRepository.instance.listarMovimentacoes();
    setState(() {
      _movimentacoes = dados;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livro de Movimentações'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movimentacoes.isEmpty
          ? _buildListaVazia()
          : _buildListaMovimentacoes(),
    );
  }

  Widget _buildListaVazia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma movimentação registada.',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildListaMovimentacoes() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _movimentacoes.length,
      itemBuilder: (context, index) {
        final mov = _movimentacoes[index];
        final bool isIndividual = mov['tipo_servico'] == 'Manejo Individual';

        String dataExibicao = mov['data_movimentacao'];
        if (dataExibicao.contains('T')) {
          final dataObj = DateTime.parse(dataExibicao);
          dataExibicao =
              "${dataObj.day.toString().padLeft(2, '0')}/${dataObj.month.toString().padLeft(2, '0')}/${dataObj.year}";
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isIndividual ? Colors.teal[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isIndividual ? Colors.teal : Colors.blue,
                        ),
                      ),
                      child: Text(
                        mov['tipo_servico'].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isIndividual
                              ? Colors.teal[800]
                              : Colors.blue[800],
                        ),
                      ),
                    ),
                    Text(
                      dataExibicao,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildLocalCard(
                        'ORIGEM',
                        mov['pasto_origem'],
                        mov['lote_original'],
                        Colors.orange,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: _buildLocalCard(
                        'DESTINO',
                        mov['pasto_destino'],
                        mov['novo_lote'],
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      isIndividual ? Icons.pets : Icons.format_list_numbered,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isIndividual
                          ? '${mov['observacoes']}'
                          : '${mov['quantidade_animais']} Animais Transferidos',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (mov['responsavel'] != null &&
                    mov['responsavel'] != '-') ...[
                  const SizedBox(height: 4),
                  Text(
                    'Responsável: ${mov['responsavel']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocalCard(
    String titulo,
    String? pasto,
    String? lote,
    MaterialColor cor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.grass, size: 14, color: cor[700]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  pasto ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.numbers, size: 14, color: cor[700]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Lote: ${lote ?? '-'}',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
