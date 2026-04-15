import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/zootecnia_service.dart';
import '../../shared/widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
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
    if (!mounted) return;
    setState(() => _isLoading = true);

    final results = await Future.wait([
      ZootecniaService.instance.obterResumoPorSexo(),
      ZootecniaService.instance.obterLotacaoPorPasto(),
      ZootecniaService.instance.obterEstatisticaReproducao(),
    ]);

    if (!mounted) return;
    setState(() {
      _resumoSexo = results[0] as Map<String, int>;
      _lotacaoPasto = results[1] as List<Map<String, dynamic>>;
      _statsRepro = results[2] as Map<String, int>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral da Fazenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _carregarMetricas,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : RefreshIndicator(
              onRefresh: _carregarMetricas,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CardRebanhoTotal(resumoSexo: _resumoSexo),
                    _CardEficienciaReprodutiva(statsRepro: _statsRepro),
                    _CardLotacaoPasto(lotacaoPasto: _lotacaoPasto),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Card: Composição do Rebanho ─────────────────────────────────────────────

class _CardRebanhoTotal extends StatelessWidget {
  const _CardRebanhoTotal({required this.resumoSexo});

  final Map<String, int> resumoSexo;

  @override
  Widget build(BuildContext context) {
    final total = resumoSexo['Total'] ?? 0;
    final machos = resumoSexo['Machos'] ?? 0;
    final femeas = resumoSexo['Fêmeas'] ?? 0;
    final percMachos = total > 0 ? machos / total : 0.0;
    final percFemeas = total > 0 ? femeas / total : 0.0;

    return StatCard(
      titulo: 'COMPOSIÇÃO DO REBANHO',
      icone: Icons.pets,
      iconColor: AppTheme.secondary,
      child: Column(
        children: [
          // Total em destaque
          Text(
            total.toString(),
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              height: 1,
            ),
          ),
          const Text(
            'Animais Ativos',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Barra de proporção
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                _ProporcaoBar(
                  flex: (percMachos * 100).toInt().clamp(1, 99),
                  color: const Color(0xFF1565C0),
                ),
                _ProporcaoBar(
                  flex: (percFemeas * 100).toInt().clamp(1, 99),
                  color: const Color(0xFFAD1457),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Legenda(
                cor: const Color(0xFF1565C0),
                titulo: 'Machos',
                valor: machos,
              ),
              _Legenda(
                cor: const Color(0xFFAD1457),
                titulo: 'Fêmeas',
                valor: femeas,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Card: Eficiência Reprodutiva ────────────────────────────────────────────

class _CardEficienciaReprodutiva extends StatelessWidget {
  const _CardEficienciaReprodutiva({required this.statsRepro});

  final Map<String, int> statsRepro;

  @override
  Widget build(BuildContext context) {
    final prenhes = statsRepro['Prenhe'] ?? 0;
    final vazias = statsRepro['Vazia'] ?? 0;
    final aguardando = statsRepro['Aguardando Diagnóstico'] ?? 0;
    final totalDiag = prenhes + vazias;
    final taxa = totalDiag > 0 ? prenhes / totalDiag : 0.0;

    return StatCard(
      titulo: 'EFICIÊNCIA REPRODUTIVA',
      icone: Icons.favorite_rounded,
      iconColor: const Color(0xFFAD1457),
      child: Column(
        children: [
          Row(
            children: [
              // Taxa em texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Taxa de Prenhez',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(taxa * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Indicador circular
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: taxa,
                      backgroundColor: Colors.red[100],
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.success,
                      ),
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                    ),
                    const Icon(
                      Icons.child_friendly_rounded,
                      color: AppTheme.success,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats secundários
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DadoVertical(
                titulo: 'Prenhes',
                valor: prenhes.toString(),
                cor: AppTheme.success,
              ),
              _DadoVertical(
                titulo: 'Vazias',
                valor: vazias.toString(),
                cor: AppTheme.error,
              ),
              _DadoVertical(
                titulo: 'Aguardando',
                valor: aguardando.toString(),
                cor: AppTheme.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Card: Lotação por Pasto ─────────────────────────────────────────────────

class _CardLotacaoPasto extends StatelessWidget {
  const _CardLotacaoPasto({required this.lotacaoPasto});

  final List<Map<String, dynamic>> lotacaoPasto;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      titulo: 'MAPA DE LOTAÇÃO (PASTOS)',
      icone: Icons.grass_rounded,
      iconColor: AppTheme.primaryLight,
      child: lotacaoPasto.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Nenhum pasto com animais ativos.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lotacaoPasto.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pasto = lotacaoPasto[index];
                final maxAnimais = lotacaoPasto[0]['quantidade'] as int;
                final qtdAtual = pasto['quantidade'] as int;
                final proporcao = maxAnimais > 0 ? qtdAtual / maxAnimais : 0.0;

                return _PastoItem(
                  nome: pasto['pasto_nome'] as String,
                  quantidade: qtdAtual,
                  proporcao: proporcao,
                );
              },
            ),
    );
  }
}

// ─── Sub-widgets reutilizáveis ───────────────────────────────────────────────

class _ProporcaoBar extends StatelessWidget {
  const _ProporcaoBar({required this.flex, required this.color});
  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(height: 14, color: color),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({
    required this.cor,
    required this.titulo,
    required this.valor,
  });
  final Color cor;
  final String titulo;
  final int valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: cor),
        const SizedBox(width: 6),
        Text(
          '$titulo: ',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Text(
          valor.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

class _DadoVertical extends StatelessWidget {
  const _DadoVertical({
    required this.titulo,
    required this.valor,
    required this.cor,
  });
  final String titulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: cor,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _PastoItem extends StatelessWidget {
  const _PastoItem({
    required this.nome,
    required this.quantidade,
    required this.proporcao,
  });
  final String nome;
  final int quantidade;
  final double proporcao;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$quantidade cabeças',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: proporcao,
          backgroundColor: AppTheme.primarySurface,
          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryLight),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
