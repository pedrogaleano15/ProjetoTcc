import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  Map<String, int> _resumoSexo = {'Machos': 0, 'Fêmeas': 0, 'Total': 0};
  List<Map<String, dynamic>> _lotacaoPasto = [];
  Map<String, int> _statsRepro = {
    'Prenhe': 0,
    'Vazia': 0,
    'Aguardando Diagnóstico': 0,
    'Aborto': 0,
  };

  @override
  void initState() {
    super.initState();
    _carregarMetricas();
  }

  Future<void> _carregarMetricas() async {
    final sexo = await DatabaseHelper.instance.obterResumoPorSexo();
    final pasto = await DatabaseHelper.instance.obterLotacaoPorPasto();
    final repro = await DatabaseHelper.instance.obterEstatisticaReproducao();

    if (mounted) {
      setState(() {
        _resumoSexo = sexo;
        _lotacaoPasto = pasto;
        _statsRepro = repro;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Visão Geral da Fazenda'),
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarMetricas,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardRebanhoTotal(),
                    const SizedBox(height: 16),
                    _buildCardEficienciaReprodutiva(),
                    const SizedBox(height: 16),
                    _buildCardLotacaoPasto(),
                  ],
                ),
              ),
            ),
    );
  }

  // --- 1. CARD: REBANHO TOTAL ---
  Widget _buildCardRebanhoTotal() {
    int total = _resumoSexo['Total'] ?? 0;
    int machos = _resumoSexo['Machos'] ?? 0;
    int femeas = _resumoSexo['Fêmeas'] ?? 0;

    double percMachos = total > 0 ? machos / total : 0.0;
    double percFemeas = total > 0 ? femeas / total : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.pets, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'COMPOSIÇÃO DO REBANHO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              total.toString(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Text(
              'Animais Ativos',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Barra de Progresso Dupla Falsificada com Row
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: (percMachos * 100).toInt(),
                    child: Container(height: 12, color: Colors.blue),
                  ),
                  Expanded(
                    flex: (percFemeas * 100).toInt(),
                    child: Container(height: 12, color: Colors.pink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegenda(Colors.blue, 'Machos', machos),
                _buildLegenda(Colors.pink, 'Fêmeas (Matrizes)', femeas),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. CARD: EFICIÊNCIA REPRODUTIVA ---
  Widget _buildCardEficienciaReprodutiva() {
    int prenhes = _statsRepro['Prenhe'] ?? 0;
    int vazias = _statsRepro['Vazia'] ?? 0;
    int aguardando = _statsRepro['Aguardando Diagnóstico'] ?? 0;
    int totalDiagnosticado = prenhes + vazias; // Apenas as que já têm resultado

    // Taxa de Prenhez (Prenhes / (Prenhes + Vazias))
    double taxaPrenhez = totalDiagnosticado > 0
        ? (prenhes / totalDiagnosticado)
        : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite, color: Colors.pink),
                SizedBox(width: 8),
                Text(
                  'EFICIÊNCIA REPRODUTIVA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Taxa de Prenhez',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${(taxaPrenhez * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: taxaPrenhez,
                        backgroundColor: Colors.red[100],
                        color: Colors.green,
                        strokeWidth: 8,
                      ),
                    ),
                    const Icon(Icons.child_friendly, color: Colors.green),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDadoVertical('Prenhes', prenhes.toString(), Colors.green),
                _buildDadoVertical('Vazias', vazias.toString(), Colors.red),
                _buildDadoVertical(
                  'Aguardando',
                  aguardando.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. CARD: LOTAÇÃO DE PASTO ---
  Widget _buildCardLotacaoPasto() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grass, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'MAPA DE LOTAÇÃO (PASTOS)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),

            if (_lotacaoPasto.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text("Nenhum pasto com animais ativos.")),
              )
            else
              ListView.builder(
                shrinkWrap: true, // Necessário dentro de uma ScrollView
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lotacaoPasto.length,
                itemBuilder: (context, index) {
                  final pasto = _lotacaoPasto[index];
                  int maxAnimais =
                      _lotacaoPasto[0]['quantidade']
                          as int; // O primeiro tem sempre o maior número por causa do ORDER BY
                  int qtdAtual = pasto['quantidade'] as int;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pasto['pasto_nome'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$qtdAtual cabeças',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: maxAnimais > 0
                              ? qtdAtual / maxAnimais
                              : 0, // Calcula o preenchimento relativo ao maior pasto
                          backgroundColor: Colors.green[50],
                          color: Colors.green[400],
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildLegenda(Color cor, String titulo, int valor) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: cor),
        const SizedBox(width: 4),
        Text(
          '$titulo: ',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        Text(
          valor.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDadoVertical(String titulo, String valor, Color cor) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
