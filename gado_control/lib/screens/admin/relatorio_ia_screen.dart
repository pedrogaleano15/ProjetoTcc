import 'package:flutter/material.dart';
import '../../core/services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../components/grafico_peso_widget.dart';

class RelatorioIaScreen extends StatefulWidget {
  // Recebe os dados brutos do gado transformados em texto
  final String dadosGado;

  RelatorioIaScreen({required this.dadosGado});

  @override
  _RelatorioIaScreenState createState() => _RelatorioIaScreenState();
}

class _RelatorioIaScreenState extends State<RelatorioIaScreen> {
  String _relatorio =
      "A processar os dados do rebanho com Inteligência Artificial...\nIsto pode demorar alguns segundos.";
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _gerar(); // Chama a IA assim que o ecrã abre
  }

  void _gerar() async {
    // Comunica com o ficheiro gemini_service.dart
    final resultado = await GeminiService.gerarRelatorio(widget.dadosGado);

    setState(() {
      _relatorio = resultado;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Análise Inteligente (IA)"),
        backgroundColor:
            Colors.deepPurple[800], // Cor diferente para destacar a IA
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _carregando
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.deepPurple[800]),
                    SizedBox(height: 20),
                    Text(
                      "A analisar dados zootécnicos...",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                // Envolvemos tudo numa Column para empilhar o Gráfico e o Texto
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. AQUI ENTRA O SEU GRÁFICO:
                    const GraficoPesoWidget(),

                    const SizedBox(
                      height: 24,
                    ), // Espaço entre o gráfico e o texto

                    const Divider(
                      color: Colors.grey,
                    ), // Uma linha sutil separando os dois

                    const SizedBox(height: 16),

                    // 2. AQUI CONTINUA O SEU RELATÓRIO DA IA:
                    MarkdownBody(
                      data: _relatorio,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        h1: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[800],
                        ),
                        h2: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[700],
                        ),
                        h3: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        listBullet: const TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
