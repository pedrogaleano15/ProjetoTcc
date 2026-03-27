import 'package:flutter/material.dart';
import '../../models/vacina_model.dart';
import '../../core/database/db_helper.dart';

class CartaoVacinacaoScreen extends StatefulWidget {
  final int animalId;

  const CartaoVacinacaoScreen({Key? key, required this.animalId})
    : super(key: key);

  @override
  _CartaoVacinacaoScreenState createState() => _CartaoVacinacaoScreenState();
}

class _CartaoVacinacaoScreenState extends State<CartaoVacinacaoScreen> {
  List<Vacina> vacinas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarVacinas();
  }

  Future<void> _carregarVacinas() async {
    final dados = await DatabaseHelper.instance.listarVacinasPorAnimal(
      widget.animalId,
    );
    setState(() {
      vacinas = dados.map((item) => Vacina.fromMap(item)).toList();
      isLoading = false;
    });
  }

  // Abre a janela para registar uma vacina
  void _mostrarDialogNovaVacina() {
    final dataAplicacaoController = TextEditingController();
    final proximaDoseController = TextEditingController();
    String? vacinaSelecionada;

    final List<String> padraoSanitario = [
      'Brucelose (Fêmeas 3 a 8 meses)',
      'Carbúnculo Sintomático (1ª aos 4 meses)',
      'Botulismo (Anual)',
      'Paratifo - Bezerros (15 a 20 dias)',
      'Paratifo - Vacas (8º mês gestação)',
      'Aftosa',
      'Dectomax / Vermífugo',
      'Outra...',
    ];

    showDialog(
      context: context,
      builder: (context) {
        // O StatefulBuilder é necessário para atualizar a tela dentro do pop-up
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Registrar Vacina'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: vacinaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Selecione a Vacina / Manejo',
                        border: OutlineInputBorder(),
                      ),
                      items: padraoSanitario.map((String vacina) {
                        return DropdownMenuItem<String>(
                          value: vacina,
                          child: Text(vacina, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (novoValor) {
                        setStateDialog(() {
                          vacinaSelecionada = novoValor;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 1. DATA E HORA DA APLICAÇÃO (COM CALENDÁRIO)
                    // ==========================================
                    TextFormField(
                      controller: dataAplicacaoController,
                      readOnly: true, // Bloqueia o teclado
                      decoration: const InputDecoration(
                        labelText: 'Data e Hora da Aplicação',
                        hintText: 'Toque para escolher...',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        DateTime? data = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (data != null) {
                          TimeOfDay? hora = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (hora != null) {
                            setStateDialog(() {
                              String d = data.day.toString().padLeft(2, '0');
                              String m = data.month.toString().padLeft(2, '0');
                              String a = data.year.toString();
                              String h = hora.hour.toString().padLeft(2, '0');
                              String min = hora.minute.toString().padLeft(
                                2,
                                '0',
                              );
                              dataAplicacaoController.text = "$d/$m/$a $h:$min";
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 2. DATA E HORA DA PRÓXIMA DOSE (COM CALENDÁRIO)
                    // ==========================================
                    TextFormField(
                      controller: proximaDoseController,
                      readOnly: true, // Bloqueia o teclado
                      decoration: const InputDecoration(
                        labelText: 'Próxima Dose (Opcional)',
                        hintText: 'Toque para escolher...',
                        prefixIcon: Icon(Icons.edit_calendar),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        DateTime? data = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (data != null) {
                          TimeOfDay? hora = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (hora != null) {
                            setStateDialog(() {
                              String d = data.day.toString().padLeft(2, '0');
                              String m = data.month.toString().padLeft(2, '0');
                              String a = data.year.toString();
                              String h = hora.hour.toString().padLeft(2, '0');
                              String min = hora.minute.toString().padLeft(
                                2,
                                '0',
                              );
                              proximaDoseController.text = "$d/$m/$a $h:$min";
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  onPressed: () async {
                    if (vacinaSelecionada != null &&
                        dataAplicacaoController.text.isNotEmpty) {
                      final novaVacina = Vacina(
                        animalId: widget.animalId,
                        nomeVacina: vacinaSelecionada!,
                        dataAplicacao: dataAplicacaoController.text,
                        proximaDose: proximaDoseController.text.isEmpty
                            ? 'Não agendada'
                            : proximaDoseController.text,
                      );

                      // Salva no SQLite
                      await DatabaseHelper.instance.inserirVacina(
                        novaVacina.toMap(),
                      );

                      if (mounted) {
                        Navigator.pop(context); // Fecha a janelinha
                        _carregarVacinas(); // Atualiza a lista na tela
                      }
                    }
                  },
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartão de Vacinação'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vacinas.isEmpty
          ? const Center(
              child: Text("Nenhuma vacina registada para este animal."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vacinas.length,
              itemBuilder: (context, index) {
                final vacina = vacinas[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.vaccines, color: Colors.white),
                    ),
                    title: Text(
                      vacina.nomeVacina,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Aplicada em: ${vacina.dataAplicacao}"),
                        Text(
                          "Próxima dose: ${vacina.proximaDose}",
                          style: TextStyle(
                            color: vacina.proximaDose == 'Não agendada'
                                ? Colors.grey
                                : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogNovaVacina,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Registar Vacina"),
      ),
    );
  }
}
