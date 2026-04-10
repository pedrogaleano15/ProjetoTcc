import 'package:flutter/material.dart';
import 'package:gado_control/screens/animal/form_desmame.dart';
import 'package:gado_control/screens/animal/form_morte.dart';
import 'package:gado_control/screens/relatorios/card_vacinacao_screen.dart';
import 'package:gado_control/screens/saude_reproducao/form_doenca.dart';
import 'package:gado_control/screens/saude_reproducao/form_inseminacao.dart';
import 'package:gado_control/screens/saude_reproducao/form_pesagem.dart';
import 'package:gado_control/screens/saude_reproducao/historico_manejo_screen.dart';

// Agora é um Future! A tela de perfil vai esperar essa janelinha fechar para atualizar os dados
Future<void> mostrarMenuManejo(
  BuildContext context,
  Map<String, dynamic> animal,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite que a lista suba corretamente
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final bottomPadding = MediaQuery.of(context).padding.bottom;

      return Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(
                  bottom: 10,
                ), // ERRO CORRIGIDO AQUI!
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Manejo: ${animal['identificacao'] ?? animal['brinco']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),

              _itemMenu(
                context,
                Icons.history,
                Colors.brown,
                'Ver Histórico',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HistoricoManejoScreen(animal: animal),
                    ),
                  );
                },
              ),

              _itemMenu(
                context,
                Icons.scale,
                Colors.teal,
                'Registar Pesagem',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormPesagemScreen(animal: animal),
                    ),
                  );
                },
              ),

              _itemMenu(
                context,
                Icons.vaccines,
                Colors.blue,
                'Saúde e Vacinação',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CartaoVacinacaoScreen(animal: animal),
                    ),
                  );
                },
              ),

              _itemMenu(
                context,
                Icons.sick,
                Colors.redAccent,
                'Reportar Doença',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormDoencaScreen(animal: animal),
                    ),
                  );
                },
              ),

              _itemMenu(
                context,
                Icons.child_care,
                Colors.orange,
                'Registar Desmame',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormDesmameScreen(animal: animal),
                    ),
                  );
                },
              ),

              _itemMenu(
                context,
                Icons.favorite,
                Colors.pink,
                'Registar Inseminação',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FormInseminacaoScreen(animal: animal),
                    ),
                  );
                },
              ),

              _itemMenu(
                context,
                Icons.warning,
                Colors.black,
                'Registar Morte',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormMorteScreen(animal: animal),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _itemMenu(
  BuildContext context,
  IconData icone,
  Color cor,
  String titulo,
  VoidCallback acao,
) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: cor,
      child: Icon(icone, color: Colors.white, size: 20),
    ),
    title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
    onTap: acao,
  );
}
