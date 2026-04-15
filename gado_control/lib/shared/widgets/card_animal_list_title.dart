import 'package:flutter/material.dart';
import '../../core/services/zootecnia_service.dart';
import '../../screens/saude_reproducao/form_pesagem.dart';
import '../../screens/saude_reproducao/form_doenca.dart';
import '../../screens/saude_reproducao/form_vacinacao.dart';
import '../../screens/saude_reproducao/form_inseminacao.dart';
import '../../screens/animal/form_desmame.dart';
import '../../screens/animal/form_morte.dart';

class CardAnimalListTile extends StatelessWidget {
  final Map<String, dynamic> animal;
  final VoidCallback onTap;
  final String modoLista; // 'Completo', 'Inseminacao', 'Desmame', 'Descarte'

  const CardAnimalListTile({
    Key? key,
    required this.animal,
    required this.onTap,
    this.modoLista = 'Completo', // Por padrão é completo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMacho = animal['sexo'] == 'Macho';
    final bool isMorto = animal['status'] == 'Morto';

    // Calcula a idade e categoria
    final zootecnia = ZootecniaService.instance.classificarAnimal(
      animal['data_nascimento'],
      animal['sexo'],
    );
    String categoria = zootecnia['categoria'];
    String idadeTexto = zootecnia['idade_texto'];
    int mesesDeVida = zootecnia['meses'] ?? 0;
    bool jaPassouDaIdadeDesmame = mesesDeVida > 12;

    Color corPrincipal = isMorto
        ? Colors.grey[600]!
        : (isMacho ? Colors.blue[700]! : Colors.pink[700]!);
    Color corFundo = isMorto ? Colors.grey[200]! : Colors.white;

    return Card(
      elevation: 2,
      color: corFundo,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Clicar no cartão inteiro abre o perfil
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === PARTE SUPERIOR: INFORMAÇÕES ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: corPrincipal.withOpacity(0.15),
                    child: Icon(
                      isMorto
                          ? Icons.warning
                          : (isMacho ? Icons.male : Icons.female),
                      color: corPrincipal,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Brinco: ${animal['identificacao']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isMorto
                                    ? Colors.grey[700]
                                    : Colors.black87,
                                decoration: isMorto
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (isMorto)
                              const Text(
                                'INATIVO',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // RESTAURADO: Lote e Pasto bem visíveis!
                        Text(
                          'Lote: ${animal['lote'] ?? '-'}  |  Pasto: ${animal['pasto'] ?? '-'}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // ETIQUETAS INTELIGENTES (Chips)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildChip(categoria, corPrincipal),
                            _buildChip(idadeTexto, Colors.orange[800]!),
                            if (animal['raca'] != null)
                              _buildChip(animal['raca'], Colors.brown),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // === PARTE INFERIOR: BOTÕES DE MANEJO ===
              if (!isMorto) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                _buildBarraDeBotoes(context, isMacho, jaPassouDaIdadeDesmame),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // LÓGICA DE QUAIS BOTÕES MOSTRAR DEPENDENDO DA TELA
  Widget _buildBarraDeBotoes(
    BuildContext context,
    bool isMacho,
    bool jaPassouDaIdade,
  ) {
    List<Widget> botoes = [];

    if (modoLista == 'Completo') {
      botoes = [
        _buildBotaoAcao(
          context,
          Icons.vaccines,
          'Vacinar',
          Colors.teal,
          FormVacinacaoScreen(animal: animal),
        ),
        _buildBotaoAcao(
          context,
          Icons.scale,
          'Pesar',
          Colors.green,
          FormPesagemScreen(animal: animal),
        ),
        _buildBotaoAcao(
          context,
          Icons.medical_services,
          'Saúde',
          Colors.red,
          FormDoencaScreen(animal: animal),
        ),
        // Acesso normal: Passa a regra restrita automaticamente (isVacaChance = false por padrão)
        if (!isMacho)
          _buildBotaoAcao(
            context,
            Icons.favorite,
            'Inseminar',
            Colors.pink,
            FormInseminacaoScreen(animal: animal),
          ),
        if (!jaPassouDaIdade)
          _buildBotaoAcao(
            context,
            Icons.grass,
            'Desmamar',
            Colors.orange,
            FormDesmameScreen(animal: animal),
          ),
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: botoes),
      );
    } else if (modoLista == 'Inseminacao') {
      return _buildBotaoAcao(
        context,
        Icons.favorite,
        'Registar Inseminação',
        Colors.pink,
        FormInseminacaoScreen(animal: animal),
        expandido: true,
      );
    } else if (modoLista == 'Desmame') {
      return _buildBotaoAcao(
        context,
        Icons.grass,
        'Registar Desmame',
        Colors.orange,
        FormDesmameScreen(animal: animal),
        expandido: true,
      );
    } else if (modoLista == 'Descarte') {
      // === LISTA DE REVISÃO / DESCARTE ===
      // Aqui o produtor tem as duas opções finais
      return Row(
        children: [
          Expanded(
            child: _buildBotaoAcao(
              context,
              Icons.favorite,
              'Dar Chance (IA)',
              Colors.pink,
              FormInseminacaoScreen(
                animal: animal,
                isVacaChance: true,
              ), // A CHAVE DE ACESSO!
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBotaoAcao(
              context,
              Icons.warning,
              'Vender / Abater',
              Colors.red[900]!,
              FormMorteScreen(animal: animal),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // Estilo das Etiquetas
  Widget _buildChip(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        border: Border.all(color: cor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Construtor dos botões rápidos
  Widget _buildBotaoAcao(
    BuildContext context,
    IconData icone,
    String texto,
    Color cor,
    Widget formScreen, {
    bool expandido = false,
  }) {
    Widget botao = InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => formScreen),
        ).then(
          (_) => onTap(),
        ); // Ao fechar o formulário, recarrega a lista chamando o onTap do cartão
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: expandido
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(icone, color: cor, size: 18),
            const SizedBox(width: 6),
            Text(
              texto,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    if (expandido) {
      return Row(children: [Expanded(child: botao)]);
    }
    return botao;
  }
}
