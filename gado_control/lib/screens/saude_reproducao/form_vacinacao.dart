import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormVacinacaoScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormVacinacaoScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _FormVacinacaoScreenState createState() => _FormVacinacaoScreenState();
}

class _FormVacinacaoScreenState extends State<FormVacinacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vacinaController = TextEditingController();

  DateTime _dataAplicacao = DateTime.now();
  DateTime? _proximaDose;
  bool _temReforco = false;

  void _salvarVacina() async {
    if (!_formKey.currentState!.validate()) return;

    final dados = {
      'animal_id': widget.animal['identificacao'].toString(),
      'nome_vacina': _vacinaController.text,
      'data_aplicacao': _dataAplicacao.toIso8601String(),
      'proxima_dose': _temReforco && _proximaDose != null
          ? _proximaDose!.toIso8601String()
          : '',
    };

    await DatabaseHelper.instance.inserirVacina(dados);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vacina registada com sucesso!'),
        backgroundColor: Colors.teal,
      ),
    );
    Navigator.pop(context, true); // Retorna true para atualizar o perfil
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacinar: ${widget.animal['identificacao']}'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _vacinaController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Vacina (Ex: Aftosa, Raiva...)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vaccines),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // DATA DE APLICAÇÃO
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: const Text('Data da Aplicação'),
                subtitle: Text(
                  "${_dataAplicacao.day}/${_dataAplicacao.month}/${_dataAplicacao.year}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final pick = await showDatePicker(
                    context: context,
                    initialDate: _dataAplicacao,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pick != null) setState(() => _dataAplicacao = pick);
                },
              ),
              const SizedBox(height: 16),

              // REFORÇO / PRÓXIMA DOSE
              CheckboxListTile(
                title: const Text("Exige dose de reforço?"),
                value: _temReforco,
                activeColor: Colors.teal,
                onChanged: (bool? val) {
                  setState(() {
                    _temReforco = val!;
                    if (_temReforco && _proximaDose == null) {
                      _proximaDose = _dataAplicacao.add(
                        const Duration(days: 30),
                      ); // Padrão 30 dias
                    }
                  });
                },
              ),

              if (_temReforco)
                ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.teal[200]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  tileColor: Colors.teal[50],
                  leading: const Icon(Icons.update, color: Colors.teal),
                  title: const Text('Data do Reforço'),
                  subtitle: Text(
                    _proximaDose != null
                        ? "${_proximaDose!.day}/${_proximaDose!.month}/${_proximaDose!.year}"
                        : "Selecione",
                  ),
                  onTap: () async {
                    final pick = await showDatePicker(
                      context: context,
                      initialDate: _proximaDose ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (pick != null) setState(() => _proximaDose = pick);
                  },
                ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _salvarVacina,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "SALVAR VACINA",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
