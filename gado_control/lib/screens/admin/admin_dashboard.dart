import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../relatorios/historico_movimentacoes_screen.dart';
import '../dashboard/menu_manejo.dart';
import 'relatorio_ia_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Painel do Gestor'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSaudacao(),
              const SizedBox(height: 24),
              const Text(
                'MÓDULOS DE GESTÃO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildGrid(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaudacao() {
    final hora = DateTime.now().hour;
    final saudacao = hora < 12
        ? 'Bom dia'
        : hora < 18
        ? 'Boa tarde'
        : 'Boa noite';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondary, AppTheme.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$saudacao, Gestor! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'O que vamos gerenciar hoje?',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final modulos = [
      _ModuloInfo(
        titulo: 'Visão Geral (BI)',
        subtitulo: 'Gráficos e indicadores',
        icone: Icons.pie_chart_rounded,
        cor: AppTheme.primary,
        tela: const DashboardScreen(),
      ),
      _ModuloInfo(
        titulo: 'Auditoria',
        subtitulo: 'Histórico de eventos',
        icone: Icons.history_rounded,
        cor: AppTheme.info,
        tela: const HistoricoMovimentacoesScreen(),
      ),
      _ModuloInfo(
        titulo: 'Gestão do Rebanho',
        subtitulo: 'Lista completa de animais',
        icone: Icons.pets_rounded,
        cor: AppTheme.secondary,
        tela: const MenuManejoScreen(),
      ),
      _ModuloInfo(
        titulo: 'Análise com IA',
        subtitulo: 'Laudo Gemini do rebanho',
        icone: Icons.psychology_rounded,
        cor: const Color(0xFF6A1B9A),
        tela: const RelatorioIaScreen(), // ← Agora funcional!
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: modulos.length,
      itemBuilder: (context, index) => _AdminCard(modulo: modulos[index]),
    );
  }
}

// ─── Modelo ──────────────────────────────────────────────────────────────────

class _ModuloInfo {
  const _ModuloInfo({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    required this.tela,
  });

  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final Widget? tela;
}

// ─── Card do módulo ──────────────────────────────────────────────────────────

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.modulo});

  final _ModuloInfo modulo;

  @override
  Widget build(BuildContext context) {
    final emBreve = modulo.tela == null;

    return Opacity(
      opacity: emBreve ? 0.55 : 1.0,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: emBreve ? 0 : 3,
        shadowColor: modulo.cor.withValues(alpha: 0.15),
        child: InkWell(
          onTap: emBreve
              ? () => _mostrarEmBreve(context)
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => modulo.tela!),
                ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: modulo.cor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: modulo.cor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(modulo.icone, color: modulo.cor, size: 26),
                ),
                const Spacer(),
                Text(
                  modulo.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  emBreve ? 'Em breve' : modulo.subtitulo,
                  style: TextStyle(
                    fontSize: 11,
                    color: emBreve ? AppTheme.warning : AppTheme.textSecondary,
                    fontWeight: emBreve ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarEmBreve(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${modulo.titulo} estará disponível em breve.'),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
