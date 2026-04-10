import 'package:flutter/material.dart';
import '../../screens/relatorios/relatorio_vacinacao_screen.dart';
import '../../screens/relatorios/configurar_cronograma_screen.dart';

class MenuLateralManejo extends StatelessWidget {
  const MenuLateralManejo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[800]),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.pets, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text(
                  'Gestão do Rebanho',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vaccines, color: Colors.blue),
            title: const Text('Vacinas do Rebanho'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RelatorioVacinacaoScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.orange),
            title: const Text('Cronograma (Embrapa)'),
            subtitle: const Text(
              'Editar e Gerar PDF',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfigurarCronogramaScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
