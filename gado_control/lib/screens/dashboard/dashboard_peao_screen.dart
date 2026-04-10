import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import 'menu_manejo.dart';
import 'form_movimentacao.dart';
import '../scanner/peao_scanner_screen.dart';
import '../animal/form_animal.dart';

class DashboardPeaoScreen extends StatefulWidget {
  const DashboardPeaoScreen({Key? key}) : super(key: key);

  @override
  _DashboardPeaoScreenState createState() => _DashboardPeaoScreenState();
}

class _DashboardPeaoScreenState extends State<DashboardPeaoScreen> {
  int _qtdInseminacao = 0;
  int _qtdDesmame = 0;
  int _qtdDescarte = 0;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    final analiseRepro = await DatabaseHelper.instance
        .processarRegrasReprodutivas();
    final listaDesmame = await DatabaseHelper.instance
        .listarBezerrosParaDesmame();

    if (mounted) {
      setState(() {
        _qtdInseminacao = (analiseRepro['aptas'] ?? []).length;
        _qtdDescarte = (analiseRepro['descarte'] ?? []).length;
        _qtdDesmame = listaDesmame.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel de Operações (Peão)'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormAnimalScreen()),
          ).then((_) => _carregarNotificacoes());
        },
        backgroundColor: Colors.green[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Animal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _carregarNotificacoes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ferramentas de Lote',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAcaoCard(
                      context,
                      'Transferir\nLote',
                      Icons.swap_horiz,
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormMovimentacaoScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAcaoCard(
                      context,
                      'Ler Brinco\n(Scanner)',
                      Icons.qr_code_scanner,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PeaoScannerScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Manejos Pendentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _buildListaCard(
                context,
                'Lote de Inseminação',
                'Fêmeas (+14m) aptas para IA',
                Icons.favorite,
                Colors.pink,
                'Inseminacao',
                _qtdInseminacao,
              ),
              const SizedBox(height: 12),
              _buildListaCard(
                context,
                'Lote de Desmame',
                'Bezerros (+3m) com a mãe',
                Icons.grass,
                Colors.orange,
                'Desmame',
                _qtdDesmame,
              ),
              const SizedBox(height: 12),
              _buildListaCard(
                context,
                'Revisão / Descarte',
                'Animais com falhas reprodutivas',
                Icons.money_off,
                Colors.red,
                'Descarte',
                _qtdDescarte,
              ),
              const SizedBox(height: 32),

              const Text(
                'Consulta Geral',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildListaCard(
                context,
                'Rebanho Completo',
                'Todos os animais',
                Icons.format_list_bulleted,
                Colors.green,
                'Completo',
                0,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcaoCard(
    BuildContext context,
    String titulo,
    IconData icone,
    MaterialColor cor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor[200]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icone, size: 48, color: cor[700]),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaCard(
    BuildContext context,
    String titulo,
    String subtitulo,
    IconData icone,
    MaterialColor cor,
    String modoLista,
    int badgeCount,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuManejoScreen(modoLista: modoLista),
            ),
          ).then((_) => _carregarNotificacoes());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cor[50],
                radius: 28,
                child: Icon(icone, color: cor[800], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
