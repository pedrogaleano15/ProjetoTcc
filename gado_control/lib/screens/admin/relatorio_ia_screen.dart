import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/zootecnia_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/grafico_peso_widget.dart';

// ─── Constantes visuais da tela de IA ────────────────────────────────────────
const _kCorIA = Color(0xFF4527A0); // Roxo profundo — identidade visual da IA
const _kCorIALight = Color(0xFF7B1FA2);
const _kCorIASurface = Color(0xFFF3E5F5);

class RelatorioIaScreen extends StatefulWidget {
  const RelatorioIaScreen({super.key});

  @override
  State<RelatorioIaScreen> createState() => _RelatorioIaScreenState();
}

class _RelatorioIaScreenState extends State<RelatorioIaScreen>
    with SingleTickerProviderStateMixin {
  // ── Estado ───────────────────────────────────────────────────────────────────
  TipoRelatorio _tipoSelecionado = TipoRelatorio.geral;
  String _relatorio = '';
  bool _carregando = false;
  bool _dadosCarregados = false;
  String _erro = '';

  // Dados do rebanho carregados do banco
  Map<String, int> _resumoSexo = {};
  Map<String, int> _statsRepro = {};
  List<Map<String, dynamic>> _lotacaoPasto = [];
  Map<String, List<Map<String, dynamic>>> _dadosReprodutivos = {};
  List<Map<String, dynamic>> _bezerrosDesmame = [];
  int _totalAnimais = 0;

  // Animação de pulse no ícone de IA
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _carregarDados();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Carregamento de dados ────────────────────────────────────────────────────

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final results = await Future.wait([
        ZootecniaService.instance.obterResumoPorSexo(),
        ZootecniaService.instance.obterEstatisticaReproducao(),
        ZootecniaService.instance.obterLotacaoPorPasto(),
        ZootecniaService.instance.processarRegrasReprodutivas(),
        ZootecniaService.instance.listarBezerrosParaDesmame(),
      ]);

      if (!mounted) return;
      setState(() {
        _resumoSexo = results[0] as Map<String, int>;
        _statsRepro = results[1] as Map<String, int>;
        _lotacaoPasto = results[2] as List<Map<String, dynamic>>;
        _dadosReprodutivos =
            results[3] as Map<String, List<Map<String, dynamic>>>;
        _bezerrosDesmame = results[4] as List<Map<String, dynamic>>;
        _totalAnimais = _resumoSexo['Total'] ?? 0;
        _dadosCarregados = true;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar dados do rebanho: $e';
        _carregando = false;
      });
    }
  }

  /// Formata todos os dados do banco em um texto estruturado para a IA.
  String _formatarDadosParaIA() {
    final sb = StringBuffer();

    sb.writeln('=== DADOS DO REBANHO ===');
    sb.writeln('Total de animais ativos: ${_resumoSexo['Total'] ?? 0} cabeças');
    sb.writeln('  • Machos: ${_resumoSexo['Machos'] ?? 0}');
    sb.writeln('  • Fêmeas: ${_resumoSexo['Fêmeas'] ?? 0}');

    sb.writeln('\n=== SITUAÇÃO REPRODUTIVA ===');
    _statsRepro.forEach((status, qtd) {
      sb.writeln('  • $status: $qtd fêmeas');
    });
    final prenhe = _statsRepro['Prenhe'] ?? 0;
    final totalFemeas = _resumoSexo['Fêmeas'] ?? 1;
    final taxaPrenhez = totalFemeas > 0
        ? (prenhe / totalFemeas * 100).toStringAsFixed(1)
        : '0';
    sb.writeln('  → Taxa de prenhez estimada: $taxaPrenhez%');

    sb.writeln('\n=== LOTAÇÃO POR PASTO ===');
    for (var pasto in _lotacaoPasto) {
      sb.writeln('  • ${pasto['pasto_nome']}: ${pasto['quantidade']} animais');
    }

    sb.writeln('\n=== GESTÃO REPRODUTIVA ===');
    final aptas = _dadosReprodutivos['aptas']?.length ?? 0;
    final descarte = _dadosReprodutivos['descarte']?.length ?? 0;
    sb.writeln('  • Fêmeas aptas para inseminação: $aptas');
    sb.writeln('  • Fêmeas indicadas para descarte/revisão: $descarte');

    sb.writeln('\n=== DESMAME ===');
    sb.writeln(
      '  • Bezerros com idade para desmame: ${_bezerrosDesmame.length}',
    );
    for (var b in _bezerrosDesmame.take(5)) {
      final meses = (b['idade_meses'] as num?)?.toStringAsFixed(1) ?? '?';
      sb.writeln(
        '    - ${b['identificacao']} (${b['sexo']}, ${b['raca'] ?? 'SRD'}, $meses meses, ${b['peso_atual'] ?? '?'} kg)',
      );
    }
    if (_bezerrosDesmame.length > 5) {
      sb.writeln('    ... e mais ${_bezerrosDesmame.length - 5} bezerros.');
    }

    return sb.toString();
  }

  // ── Geração do relatório ─────────────────────────────────────────────────────

  Future<void> _gerarRelatorio() async {
    if (!_dadosCarregados) {
      await _carregarDados();
    }

    setState(() {
      _carregando = true;
      _relatorio = '';
      _erro = '';
    });

    final dados = _formatarDadosParaIA();
    final resultado = await GeminiService.gerarRelatorio(
      dados,
      tipo: _tipoSelecionado,
    );

    if (!mounted) return;
    setState(() {
      _relatorio = resultado;
      _carregando = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035), // Fundo escuro — identidade IA
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSeletorTipo(),
          Expanded(child: _buildCorpo()),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _kCorIA,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: const Icon(Icons.psychology_rounded, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'Análise Inteligente',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ],
      ),
      actions: [
        if (_relatorio.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copiar relatório',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _relatorio));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Relatório copiado!'),
                  backgroundColor: _kCorIALight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSeletorTipo() {
    return Container(
      color: _kCorIA,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione o tipo de análise:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TipoRelatorio.values.map((tipo) {
                final selecionado = tipo == _tipoSelecionado;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _tipoSelecionado = tipo),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selecionado
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selecionado
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconePorTipo(tipo),
                            size: 14,
                            color: selecionado ? _kCorIA : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _labelPorTipo(tipo),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selecionado ? _kCorIA : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorpo() {
    if (_carregando) return _buildLoading();
    if (_erro.isNotEmpty) return _buildErro();
    if (_relatorio.isEmpty) return _buildTelaBemVindo();
    return _buildRelatorio();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kCorIALight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analisando dados zootécnicos...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isso pode levar alguns segundos',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: Colors.purpleAccent,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _erro,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kCorIALight,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelaBemVindo() {
    final stats = [
      _StatItem(
        label: 'Animais',
        valor: '$_totalAnimais',
        icone: Icons.pets_rounded,
        cor: AppTheme.primaryLight,
      ),
      _StatItem(
        label: 'Prenhes',
        valor:
            '${_resumoSexo['Fêmeas'] != null ? (_statsRepro['Prenhe'] ?? 0) : 0}',
        icone: Icons.favorite_rounded,
        cor: AppTheme.success,
      ),
      _StatItem(
        label: 'P/ Insem.',
        valor: '${_dadosReprodutivos['aptas']?.length ?? 0}',
        icone: Icons.science_rounded,
        cor: AppTheme.accent,
      ),
      _StatItem(
        label: 'Descarte',
        valor: '${_dadosReprodutivos['descarte']?.length ?? 0}',
        icone: Icons.warning_rounded,
        cor: AppTheme.error,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo rápido do rebanho
          if (_dadosCarregados) ...[
            const Text(
              'RESUMO DO REBANHO',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: stats
                  .map((s) => Expanded(child: _buildMiniStat(s)))
                  .toList(),
            ),
            const SizedBox(height: 28),
          ],

          // Gráfico de peso
          const GraficoPesoWidget(),
          const SizedBox(height: 28),

          // Card convite para gerar relatório
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kCorIALight.withValues(alpha: 0.3),
                  _kCorIA.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.amber,
                  size: 36,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pronto para analisar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione um tipo de análise acima e toque em "Gerar Análise" para receber um laudo zootécnico completo da sua fazenda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tipo selecionado: ${_labelPorTipo(_tipoSelecionado)}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // espaço pro FAB
        ],
      ),
    );
  }

  Widget _buildMiniStat(_StatItem stat) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: stat.cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stat.cor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(stat.icone, color: stat.cor, size: 18),
          const SizedBox(height: 4),
          Text(
            stat.valor,
            style: TextStyle(
              color: stat.cor,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          Text(
            stat.label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatorio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do relatório
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCorIALight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labelPorTipo(_tipoSelecionado),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Gerado em ${_formatarDataHora()}  •  $_totalAnimais animais analisados',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: _gerarRelatorio,
                  tooltip: 'Regenerar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Conteúdo Markdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: MarkdownBody(
              data: _relatorio,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF1C1C1C),
                ),
                h1: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kCorIA,
                  height: 2.0,
                ),
                h2: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kCorIALight,
                  height: 1.8,
                ),
                h3: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1C),
                  height: 1.7,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1C),
                ),
                listBullet: const TextStyle(fontSize: 15, color: _kCorIA),
                blockquoteDecoration: BoxDecoration(
                  color: _kCorIASurface,
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: _kCorIALight, width: 4),
                  ),
                ),
                code: const TextStyle(
                  backgroundColor: Color(0xFFF3E5F5),
                  color: _kCorIA,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget? _buildFab() {
    if (_carregando) return null;
    return FloatingActionButton.extended(
      onPressed: _gerarRelatorio,
      backgroundColor: _kCorIALight,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.auto_awesome_rounded),
      label: Text(
        _relatorio.isEmpty ? 'Gerar Análise' : 'Nova Análise',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _labelPorTipo(TipoRelatorio tipo) {
    switch (tipo) {
      case TipoRelatorio.geral:
        return 'Geral';
      case TipoRelatorio.reproducao:
        return 'Reprodução';
      case TipoRelatorio.sanidade:
        return 'Sanidade';
      case TipoRelatorio.peso:
        return 'Peso/Nutrição';
      case TipoRelatorio.descarte:
        return 'Descarte';
    }
  }

  IconData _iconePorTipo(TipoRelatorio tipo) {
    switch (tipo) {
      case TipoRelatorio.geral:
        return Icons.dashboard_rounded;
      case TipoRelatorio.reproducao:
        return Icons.favorite_rounded;
      case TipoRelatorio.sanidade:
        return Icons.medical_services_rounded;
      case TipoRelatorio.peso:
        return Icons.monitor_weight_rounded;
      case TipoRelatorio.descarte:
        return Icons.swap_horiz_rounded;
    }
  }

  String _formatarDataHora() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')} às ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Modelo auxiliar ─────────────────────────────────────────────────────────

class _StatItem {
  const _StatItem({
    required this.label,
    required this.valor,
    required this.icone,
    required this.cor,
  });
  final String label;
  final String valor;
  final IconData icone;
  final Color cor;
}
