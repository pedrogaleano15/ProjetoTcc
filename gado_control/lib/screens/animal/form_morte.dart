import 'package:flutter/material.dart';
import '../../repositories/gado_repository.dart';

class FormMorteScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormMorteScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _FormMorteScreenState createState() => _FormMorteScreenState();
}

class _FormMorteScreenState extends State<FormMorteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _obsController = TextEditingController();
  DateTime _dataBaixa = DateTime.now();
  String _causaSelecionada = 'Causa Natural / Idade';

  void _registrarMorte() async {
    if (!_formKey.currentState!.validate()) return;
    final brinco = widget.animal['identificacao'].toString();

    final dados = {
      'animal_id': brinco,
      'data_baixa': _dataBaixa.toIso8601String(),
      'causa': _causaSelecionada,
      'observacoes': _obsController.text,
    };

    await GadoRepository.instance.inserirBaixa(dados);
    await GadoRepository.instance.atualizarStatusAnimal(brinco, 'Morto');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Baixa registrada. Animal inativado.'),
        backgroundColor: Colors.black,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Baixa'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                color: Colors.grey[200],
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.black54,
                    size: 32,
                  ),
                  title: Text(
                    'Brinco: ${widget.animal['identificacao']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Atenção: Esta ação inativará o animal.',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Causa da Baixa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.playlist_remove),
                ),
                value: _causaSelecionada,
                items:
                    [
                      'Causa Natural / Idade',
                      'Doença',
                      'Acidente / Fratura',
                      'Predador',
                      'Desconhecida',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) =>
                    setState(() => _causaSelecionada = newValue!),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
                title: Text(
                  "Data: ${_dataBaixa.day}/${_dataBaixa.month}/${_dataBaixa.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pick = await showDatePicker(
                    context: context,
                    initialDate: _dataBaixa,
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (pick != null) setState(() => _dataBaixa = pick);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar Baixa?'),
                        content: Text(
                          'Confirmar a morte do animal ${widget.animal['identificacao']}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _registrarMorte();
                            },
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  label: const Text(
                    'CONFIRMAR BAIXA',
                    style: TextStyle(color: Colors.white),
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
