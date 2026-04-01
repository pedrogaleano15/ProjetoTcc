import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import 'modal_opcoes_manejo.dart';

class PerfilAnimalScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const PerfilAnimalScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _PerfilAnimalScreenState createState() => _PerfilAnimalScreenState();
}

class _PerfilAnimalScreenState extends State<PerfilAnimalScreen> {
  List<Map<String, dynamic>> _doencas = [];
  bool _emQuarentena = false;
  Map<String, dynamic>? _animalAtualizado;

  @override
  void initState() {
    super.initState();
    _animalAtualizado = widget.animal;
    _carregarDadosCompletos();
  }

  // MUDANÇA 1: Transformámos a função em Future<void> para o RefreshIndicator saber quando termina
  Future<void> _carregarDadosCompletos() async {
    final idAnimal = widget.animal['id'];

    final listaAnimais = await DatabaseHelper.instance.listarAnimais();
    final animalFresco = listaAnimais.firstWhere((a) => a['id'] == idAnimal);

    final doencas = await DatabaseHelper.instance.listarDoencasPorAnimal(
      idAnimal,
    );

    if (mounted) {
      setState(() {
        _animalAtualizado = animalFresco;
        _doencas = doencas;
        _emQuarentena = doencas.any((d) => d['status_cura'] == 'Ativa');
      });
    }
  }

  void _curarAnimal(int idDoenca) async {
    await DatabaseHelper.instance.curarDoenca(
      idDoenca,
      "Tratamento concluído com sucesso.",
    );
    _carregarDadosCompletos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Animal curado! Quarentena encerrada.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animalExibido = _animalAtualizado ?? widget.animal;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ficha: ${animalExibido['identificacao'] ?? animalExibido['brinco']}',
        ),
        backgroundColor: _emQuarentena ? Colors.red[800] : Colors.green[700],
        foregroundColor: Colors.white,
      ),
      // MUDANÇA 2: Envolver o ScrollView com o RefreshIndicator
      body: RefreshIndicator(
        onRefresh: _carregarDadosCompletos, // Chama a nossa função ao arrastar
        color: Colors.green[700], // Cor da bolinha de carregamento
        child: SingleChildScrollView(
          // MUDANÇA 3: Obriga a tela a ser "rolável" mesmo se tiver poucos dados, senão o arrastar não funciona
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            children: [
              // ALERTA DE QUARENTENA VISUAL
              if (_emQuarentena)
                Container(
                  width: double.infinity,
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red[800],
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ANIMAL EM QUARENTENA',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Risco de contágio. Isole este animal do rebanho principal.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // DADOS PRINCIPAIS DO ANIMAL (COM O PESO ATUALIZADO)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.pets,
                            color: Colors.brown,
                            size: 40,
                          ),
                          title: Text(
                            'Raça: ${animalExibido['raca'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Sexo: ${animalExibido['sexo'] ?? '-'}',
                          ),
                        ),
                        const Divider(),
                        _linhaDado(
                          'Peso Atual:',
                          '${animalExibido['peso_atual'] ?? animalExibido['peso_nascimento']} kg',
                          Icons.scale,
                          destaque: true,
                        ),
                        _linhaDado(
                          'Peso Nascer:',
                          '${animalExibido['peso_nascimento']} kg',
                          Icons.monitor_weight,
                        ),
                        _linhaDado(
                          'Nascimento:',
                          animalExibido['data_nascimento'],
                          Icons.cake,
                        ),
                        _linhaDado(
                          'Mãe (ID):',
                          animalExibido['mae_identificacao'] ?? 'Desconhecida',
                          Icons.family_restroom,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // HISTÓRICO DE SAÚDE / DOENÇAS NA FICHA
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Histórico Clínico',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              _doencas.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Nenhum registo de doença para este animal."),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _doencas.length,
                      itemBuilder: (context, index) {
                        final doenca = _doencas[index];
                        bool isAtiva = doenca['status_cura'] == 'Ativa';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Icon(
                              isAtiva ? Icons.sick : Icons.healing,
                              color: isAtiva ? Colors.red : Colors.green,
                            ),
                            title: Text(
                              doenca['diagnostico'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Data: ${doenca['data_diagnostico']}\nTratamento: ${doenca['tratamento_aplicado']}',
                            ),
                            trailing: isAtiva
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () => _curarAnimal(doenca['id']),
                                    child: const Text(
                                      'Curar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Curado',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await mostrarMenuManejo(context, animalExibido);
          _carregarDadosCompletos();
        },
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.list_alt),
        label: const Text('Ações de Manejo'),
      ),
    );
  }

  Widget _linhaDado(
    String titulo,
    String valor,
    IconData icone, {
    bool destaque = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icone,
            color: destaque ? Colors.teal : Colors.grey[700],
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: destaque ? 16 : 14,
            ),
          ),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              fontSize: destaque ? 18 : 14,
              color: destaque ? Colors.teal[800] : Colors.black,
              fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
