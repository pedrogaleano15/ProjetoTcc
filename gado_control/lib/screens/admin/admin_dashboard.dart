import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart'; // A Tela de BI (Gráficos)
import '../relatorios/historico_movimentacoes_screen.dart'; // O Livro de Registros
import '../dashboard/menu_manejo.dart'; // A Tela de Rebanho Completo

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel do Gestor'),
        backgroundColor: Colors.blueGrey[900], // Cor mais sóbria para o Admin
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fazenda São Bento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Escolha o módulo de gestão:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 cartões por linha
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    context,
                    'Visão Geral (BI)',
                    Icons.pie_chart,
                    Colors.green,
                    const DashboardScreen(),
                  ),
                  _buildAdminCard(
                    context,
                    'Histórico e Auditoria',
                    Icons.history,
                    Colors.blue,
                    const HistoricoMovimentacoesScreen(),
                  ),
                  _buildAdminCard(
                    context,
                    'Gestão do Rebanho',
                    Icons.pets,
                    Colors.brown,
                    const MenuManejoScreen(), // O admin também pode aceder à lista se quiser!
                  ),
                  // Se tiver o relatório da IA, pode descomentar abaixo:
                  // _buildAdminCard(
                  //   context,
                  //   'Relatório de IA',
                  //   Icons.psychology,
                  //   Colors.deepPurple,
                  //   const RelatorioIAScreen()
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget construtor dos botões do Admin
  Widget _buildAdminCard(
    BuildContext context,
    String titulo,
    IconData icone,
    MaterialColor cor,
    Widget telaDestino,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => telaDestino),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: cor[100]!, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: cor[50],
              child: Icon(icone, size: 32, color: cor[700]),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
