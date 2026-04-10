import 'package:flutter/material.dart';

// Importe os formulários de manejo que já criámos!
import '../../screens/saude_reproducao/form_pesagem.dart';
import '../../screens/saude_reproducao/form_doenca.dart';
import '../../screens/saude_reproducao/form_vacinacao.dart';
import '../../screens/saude_reproducao/form_inseminacao.dart';

class CardAnimalListTile extends StatelessWidget {
  final Map<String, dynamic> animal;
  final VoidCallback? onTap;

  const CardAnimalListTile({Key? key, required this.animal, this.onTap})
    : super(key: key);

  // Função auxiliar para abrir os modais de manejo sem sair da tela
  void _abrirManejoRapido(BuildContext context, Widget formScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => formScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMacho = animal['sexo'] == 'Macho';
    final bool isMorto = animal['status'] == 'Morto';

    final String pasto =
        (animal['pasto'] != null && animal['pasto'].toString().isNotEmpty)
        ? animal['pasto']
        : 'Sem Pasto';
    final String lote =
        (animal['lote'] != null && animal['lote'].toString().isNotEmpty)
        ? animal['lote']
        : 'Sem Lote';
    final String? statusRepro = animal['status_reproducao'];

    // Tratamento visual para os animais Sem Brinco (SN)
    String numeroExibicao = animal['identificacao'];
    bool isSemBrinco = numeroExibicao.startsWith('SN-');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isMorto ? Colors.grey[300] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isMorto ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          // Mudámos para Column para colocar os botões por baixo
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: isMorto
                        ? Colors.grey[500]
                        : (isMacho ? Colors.blue[100] : Colors.pink[100]),
                    child: Icon(
                      isMorto
                          ? Icons.warning
                          : (isMacho ? Icons.male : Icons.female),
                      color: isMorto
                          ? Colors.white
                          : (isMacho ? Colors.blue[800] : Colors.pink[800]),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSemBrinco
                              ? 'Sem Brinco ($numeroExibicao)'
                              : 'Brinco: $numeroExibicao',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isMorto
                                ? Colors.grey[700]
                                : (isSemBrinco
                                      ? Colors.orange[800]
                                      : Colors.black),
                            decoration: isMorto
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isMorto)
                          const Text(
                            "ANIMAL INATIVO (BAIXA)",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else ...[
                          Text(
                            'Raça: ${animal['raca']}  |  Peso: ${animal['peso_atual'] ?? animal['peso_nascimento']} kg',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildEtiqueta(Icons.grass, pasto, Colors.green),
                              _buildEtiqueta(
                                Icons.numbers,
                                'Lote: $lote',
                                Colors.orange,
                              ),
                              if (!isMacho && statusRepro != null)
                                _buildEtiquetaReproducao(statusRepro),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // NOVA BARRA DE MANEJO RÁPIDO "POR FORA"
            // ==========================================
            if (!isMorto)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBotaoManejo(
                      context,
                      Icons.scale,
                      'Pesar',
                      Colors.green,
                      () => _abrirManejoRapido(
                        context,
                        FormPesagemScreen(animal: animal),
                      ),
                    ),
                    _buildBotaoManejo(
                      context,
                      Icons.vaccines,
                      'Vacinar',
                      Colors.teal,
                      () => _abrirManejoRapido(
                        context,
                        FormVacinacaoScreen(animal: animal),
                      ),
                    ),
                    _buildBotaoManejo(
                      context,
                      Icons.medical_services,
                      'Saúde',
                      Colors.red,
                      () => _abrirManejoRapido(
                        context,
                        FormDoencaScreen(animal: animal),
                      ),
                    ),
                    if (!isMacho)
                      _buildBotaoManejo(
                        context,
                        Icons.favorite,
                        'Inseminar',
                        Colors.pink,
                        () => _abrirManejoRapido(
                          context,
                          FormInseminacaoScreen(animal: animal),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget para os pequenos botões de manejo no rodapé do cartão
  Widget _buildBotaoManejo(
    BuildContext context,
    IconData icone,
    String tooltip,
    Color cor,
    VoidCallback onTap,
  ) {
    return IconButton(
      icon: Icon(icone, color: cor),
      tooltip: tooltip, // Quando o peão segurar o dedo, aparece o nome da ação
      splashRadius: 24,
      onPressed: onTap,
    );
  }

  // (Mantenha aqui os widgets _buildEtiqueta e _buildEtiquetaReproducao que já tínhamos)
  Widget _buildEtiqueta(IconData icone, String texto, MaterialColor cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cor[50],
        border: Border.all(color: cor[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 12, color: cor[800]),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: cor[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtiquetaReproducao(String status) {
    MaterialColor cor;
    IconData icone = Icons.child_friendly;
    if (status == 'Prenhe') {
      cor = Colors.green;
    } else if (status == 'Vazia') {
      cor = Colors.red;
      icone = Icons.cancel;
    } else if (status == 'Aborto') {
      cor = Colors.grey;
      icone = Icons.warning;
    } else {
      cor = Colors.blue;
      icone = Icons.hourglass_bottom;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
