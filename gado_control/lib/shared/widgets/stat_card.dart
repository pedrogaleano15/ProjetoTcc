import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Card padrão usado em todos os dashboards do GadoControl.
///
/// Garante consistência visual: sombra, bordas, cabeçalho e espaçamento.
/// Uso:
/// ```dart
/// StatCard(
///   titulo: 'COMPOSIÇÃO DO REBANHO',
///   icone: Icons.pets,
///   iconColor: Colors.brown,
///   child: MinhaMetrica(),
/// )
/// ```
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.titulo,
    required this.icone,
    required this.child,
    this.iconColor,
    this.acaoWidget,
  });

  final String titulo;
  final IconData icone;
  final Widget child;
  final Color? iconColor;

  /// Widget opcional no canto direito do cabeçalho (ex: botão de detalhes).
  final Widget? acaoWidget;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildHeader(), const Divider(height: 24), child],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(icone, color: iconColor ?? AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        if (acaoWidget != null) acaoWidget!,
      ],
    );
  }
}
