import 'package:flutter/material.dart';
import 'relatorio_cronograma_screen.dart';

// Classe que guarda o estado de cada linha da tabela
class AtividadeItem {
  String nome;
  List<bool> meses; // 12 meses (Julho a Junho)
  TextEditingController obsController;

  AtividadeItem({
    required this.nome,
    required List<int> mesesIniciais,
    required String obsInicial,
  }) : meses = List.generate(12, (index) => mesesIniciais.contains(index)),
       obsController = TextEditingController(text: obsInicial);
}

class ConfigurarCronogramaScreen extends StatefulWidget {
  const ConfigurarCronogramaScreen({Key? key}) : super(key: key);

  @override
  _ConfigurarCronogramaScreenState createState() =>
      _ConfigurarCronogramaScreenState();
}

class _ConfigurarCronogramaScreenState
    extends State<ConfigurarCronogramaScreen> {
  final List<String> _nomesMeses = [
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
  ];
  late List<AtividadeItem> _atividades;

  @override
  void initState() {
    super.initState();
    // Carregamos a base da Embrapa para facilitar, mas agora você pode alterar TUDO na tela!
    _atividades = [
      AtividadeItem(
        nome: 'Exame andrológico',
        mesesIniciais: [1],
        obsInicial: 'Machos para reprodução',
      ),
      AtividadeItem(
        nome: 'Estação de monta',
        mesesIniciais: [4, 5, 6],
        obsInicial: 'Vacas devem apresentar condições corporais de média a boa',
      ),
      AtividadeItem(
        nome: 'Diagnóstico de gestação',
        mesesIniciais: [9],
        obsInicial: 'Eliminar fêmeas vazias',
      ),
      AtividadeItem(
        nome: 'Vacina paratifo (vacas prenhas)',
        mesesIniciais: [0, 1, 2],
        obsInicial: 'Vacinar no 8º mês de gestação',
      ),
      AtividadeItem(
        nome: 'Descartes',
        mesesIniciais: [9],
        obsInicial: 'Selecionar por idade e desempenho',
      ),
      AtividadeItem(
        nome: 'Mamada do colostro / cura do umbigo',
        mesesIniciais: [1, 2, 3],
        obsInicial: 'Cortar e desinfetar o umbigo com iodo a 10%',
      ),
      AtividadeItem(
        nome: 'Dectomax (1ml)',
        mesesIniciais: [1, 2, 3],
        obsInicial: 'Controle de parasitas',
      ),
      AtividadeItem(
        nome: 'Marcar os bezerros',
        mesesIniciais: [1, 2, 3],
        obsInicial: 'Identificação a fogo ou brinco',
      ),
      AtividadeItem(
        nome: 'Pesagem dos bezerros',
        mesesIniciais: [1, 2, 3],
        obsInicial: 'Acompanhamento de ganho de peso',
      ),
      AtividadeItem(
        nome: 'Vacina paratifo (bezerros)',
        mesesIniciais: [1, 2, 3],
        obsInicial: 'Vacinar entre 15 e 20 dias de idade',
      ),
      AtividadeItem(
        nome: 'Desmama',
        mesesIniciais: [9, 10],
        obsInicial: 'Aos 6 - 7 meses de idade',
      ),
      AtividadeItem(
        nome: 'Vacina contra brucelose',
        mesesIniciais: [6],
        obsInicial: 'Fêmeas 3 a 8 meses. Marcar "V"',
      ),
      AtividadeItem(
        nome: 'Vacina carbúnculo sintomático',
        mesesIniciais: [1, 6],
        obsInicial: '1ª dose: 4-6 meses. 2ª dose: 6 meses após',
      ),
      AtividadeItem(
        nome: 'Vacina contra botulismo',
        mesesIniciais: [6],
        obsInicial: '1ª dose: 4º mês. 2ª dose: 40 dias após. Repetir anual',
      ),
      AtividadeItem(
        nome: 'Vacina contra aftosa',
        mesesIniciais: [4, 9],
        obsInicial: 'Conforme calendário oficial da região',
      ),
    ];
  }

  void _gerarPdf() {
    // Transforma as escolhas da tela no formato exato que o PDF precisa
    List<List<String>> dadosTabela = [];

    for (var ativ in _atividades) {
      List<String> linha = [ativ.nome];
      // Adiciona 'X' onde você clicou e deixou verde, e '' onde ficou cinza
      for (bool marcado in ativ.meses) {
        linha.add(marcado ? 'X' : '');
      }
      // Pega o texto exato que você digitou na caixinha de observação daquela vacina
      linha.add(ativ.obsController.text);
      dadosTabela.add(linha);
    }

    // Envia tudo pronto para a tela do PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RelatorioCronogramaScreen(dadosConfigurados: dadosTabela),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Cronograma'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _atividades.length,
        itemBuilder: (context, index) {
          final ativ = _atividades[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ativ.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Marque os meses de aplicação:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  // OS BOTÕES DOS MESES
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (mesIndex) {
                      return FilterChip(
                        label: Text(
                          _nomesMeses[mesIndex],
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: ativ.meses[mesIndex],
                        selectedColor:
                            Colors.green[300], // Fica verde se selecionado
                        onSelected: (bool selecionado) {
                          setState(() {
                            ativ.meses[mesIndex] = selecionado;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // O CAMPO DA OBSERVAÇÃO
                  TextFormField(
                    controller: ativ.obsController,
                    decoration: const InputDecoration(
                      labelText: 'Observação Específica',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gerarPdf,
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Visualizar PDF'),
      ),
    );
  }
}
