import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormInseminacaoScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const FormInseminacaoScreen({Key? key, required this.animal})
    : super(key: key);

  @override
  _FormInseminacaoScreenState createState() => _FormInseminacaoScreenState();
}

class _FormInseminacaoScreenState extends State<FormInseminacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _touroController = TextEditingController();
  final _inseminadorController = TextEditingController();
  String _tipoReproducao = 'Inseminação Artificial (IA)';
  DateTime _dataServico = DateTime.now();

  // === O GUARDA-COSTAS VIRTUAL ===
  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Regra de Idade: Travar fêmeas jovens
    String dataNascString = widget.animal['data_nascimento'];
    DateTime dataNasc;

    // Tratamento de conversão de data (aceita dd/mm/yyyy ou yyyy-mm-dd)
    if (dataNascString.contains('/')) {
      List<String> partes = dataNascString.split(' ')[0].split('/');
      dataNasc = DateTime(
        int.parse(partes[2]),
        int.parse(partes[1]),
        int.parse(partes[0]),
      );
    } else {
      dataNasc = DateTime.parse(dataNascString);
    }

    double idadeMeses = DateTime.now().difference(dataNasc).inDays / 30.44;

    if (idadeMeses < 14.0) {
      _mostrarErroCrucial(
        'AÇÃO BLOQUEADA:\nEsta fêmea tem apenas ${idadeMeses.toInt()} meses. A idade mínima para protocolo é 14 meses.',
      );
      return; // Interrompe o salvamento!
    }

    // 2. Regra de Descarte: Travar fêmeas com 2 ou mais falhas
    final historicoRepro = await DatabaseHelper.instance.listarReproducao(
      widget.animal['identificacao'],
    );
    int contagemFalhas = 0;

    // Conta quantas "Vazias" seguidas ela teve (Se houver um Parto pelo meio, a contagem seria zerada numa lógica avançada)
    for (var repro in historicoRepro) {
      if (repro['status'] == 'Vazia' || repro['status'] == 'Aborto') {
        contagemFalhas++;
      }
    }

    if (contagemFalhas >= 2) {
      _mostrarErroCrucial(
        'AÇÃO BLOQUEADA:\nEsta matriz atingiu o limite de falhas reprodutivas ($contagemFalhas tentativas "Vazias"). Deve ser encaminhada para o Lote de Descarte.',
      );
      return; // Interrompe o salvamento!
    }

    // Se passou pelos seguranças, calcula a previsão de parto (285 dias) e SALVA!
    DateTime previsaoParto = _dataServico.add(const Duration(days: 285));

    final dados = {
      'animal_id': widget.animal['identificacao'].toString(),
      'data_inseminacao': _dataServico.toIso8601String(),
      'tipo_reproducao': _tipoReproducao,
      'touro_id': _touroController.text,
      'inseminador': _inseminadorController.text,
      'previsao_parto': previsaoParto.toIso8601String(),
      'status': 'Aguardando Diagnóstico', // Status inicial
    };

    await DatabaseHelper.instance.inserirReproducao(dados);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Serviço registado com sucesso!'),
        backgroundColor: Colors.pink,
      ),
    );
    Navigator.pop(context, true);
  }

  void _mostrarErroCrucial(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.block, color: Colors.red, size: 48),
        title: const Text(
          'Bloqueio do Sistema',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          mensagem,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inseminar: ${widget.animal['identificacao']}'),
        backgroundColor: Colors.pink[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... Seus campos normais de Touro, Tipo, Data, Inseminador ...
              TextFormField(
                controller: _touroController,
                decoration: const InputDecoration(
                  labelText: 'Identificação do Touro / Palheta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.favorite, color: Colors.white),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "REGISTAR INSEMINAÇÃO",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
