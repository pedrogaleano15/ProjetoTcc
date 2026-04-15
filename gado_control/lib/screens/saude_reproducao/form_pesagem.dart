import 'package:flutter/material.dart';
import '../../core/services/calculos_service.dart';
import '../../repositories/gado_repository.dart';

class FormPesagemScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormPesagemScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _FormPesagemScreenState createState() => _FormPesagemScreenState();
}

class _FormPesagemScreenState extends State<FormPesagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesagem: ${widget.animal['identificacao']}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                color: Colors.blueGrey[50],
                child: ListTile(
                  leading: const Icon(Icons.scale),
                  title: const Text('Último Peso Registado'),
                  trailing: Text(
                    '${widget.animal['peso_atual'] ?? widget.animal['peso_nascimento']} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Novo Peso (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_chart),
                ),
                validator: (value) => value!.isEmpty ? 'Informe o peso' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  "Data da Pesagem: ${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pick = await showDatePicker(
                    context: context,
                    initialDate: _dataSelecionada,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pick != null) setState(() => _dataSelecionada = pick);
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _salvarPesagem,
                  child: const Text(
                    'REGISTAR PESAGEM',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salvarPesagem() async {
    if (_formKey.currentState!.validate()) {
      final double novoPeso =
          double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0;
      final double pesoAnterior =
          (widget.animal['peso_atual'] ?? widget.animal['peso_nascimento'])
              .toDouble();
      double gmdCalculado = CalculosService.calcularGMD(
        novoPeso,
        pesoAnterior,
        _dataSelecionada,
        DateTime.parse(
          widget.animal['data_nascimento_iso'] ??
              DateTime.now().toIso8601String(),
        ),
      );

      final novaPesagem = {
        'animal_id': widget.animal['identificacao'],
        'data_pesagem': _dataSelecionada.toIso8601String(),
        'peso_anterior': pesoAnterior,
        'peso_atual': novoPeso,
        'gmd': gmdCalculado,
        'score_corporal': 3,
      };

      await GadoRepository.instance.inserirPesagem(novaPesagem);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesagem registada!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
