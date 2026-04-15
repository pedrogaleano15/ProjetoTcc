import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../repositories/gado_repository.dart';

class FormDesmameScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormDesmameScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _FormDesmameScreenState createState() => _FormDesmameScreenState();
}

class _FormDesmameScreenState extends State<FormDesmameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _loteController = TextEditingController();
  DateTime _dataDesmame = DateTime.now();

  void _confirmarDesmame() async {
    if (!_formKey.currentState!.validate()) return;
    final brinco = widget.animal['identificacao'].toString();

    final dados = {
      'animal_id': brinco,
      'data_desmame': _dataDesmame.toIso8601String(),
      'peso_desmame':
          double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0,
      'lote_destino': _loteController.text,
    };

    await GadoRepository.instance.inserirDesmame(dados);
    await GadoRepository.instance.atualizarLoteAnimal(
      brinco,
      _loteController.text,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Desmame'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pesoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Peso Desmame (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loteController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Novo Lote (Apenas Números)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                title: Text(
                  "Data: ${_dataDesmame.day}/${_dataDesmame.month}/${_dataDesmame.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: _dataDesmame,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (p != null) setState(() => _dataDesmame = p);
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _confirmarDesmame,
                  child: const Text(
                    'FINALIZAR DESMAME',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
