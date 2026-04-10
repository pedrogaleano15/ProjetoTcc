import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class FormMovimentacaoScreen extends StatefulWidget {
  const FormMovimentacaoScreen({Key? key}) : super(key: key);

  @override
  _FormMovimentacaoScreenState createState() => _FormMovimentacaoScreenState();
}

class _FormMovimentacaoScreenState extends State<FormMovimentacaoScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _data = DateTime.now();
  String _tipoServico = 'Transferência';

  final _pastoOrigemCtrl = TextEditingController();
  final _pastoDestinoCtrl = TextEditingController();
  final _loteOrigemCtrl = TextEditingController();
  final _loteDestinoCtrl = TextEditingController();
  final _quantidadeCtrl = TextEditingController();
  final _responsavelCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  void _salvarMovimentacao() async {
    if (!_formKey.currentState!.validate()) return;

    final dados = {
      'data_movimentacao': _data.toIso8601String(),
      'tipo_servico': _tipoServico,
      'pasto_origem': _pastoOrigemCtrl.text,
      'pasto_destino': _pastoDestinoCtrl.text,
      'lote_original': _loteOrigemCtrl.text,
      'novo_lote': _loteDestinoCtrl.text.isNotEmpty
          ? _loteDestinoCtrl.text
          : _loteOrigemCtrl.text, // Se deixar vazio, mantém o mesmo lote
      'quantidade_animais': int.tryParse(_quantidadeCtrl.text) ?? 0,
      'responsavel': _responsavelCtrl.text,
      'observacoes': _obsCtrl.text,
    };

    // 1. Salva o registro no histórico de movimentações (O Caderno Digital)
    await DatabaseHelper.instance.inserirMovimentacao(dados);

    // 2. A MÁGICA: Atualiza as fichas dos bois se for Transferência!
    if (_tipoServico == 'Transferência') {
      String novoLoteFinal = _loteDestinoCtrl.text.isNotEmpty
          ? _loteDestinoCtrl.text
          : _loteOrigemCtrl.text;

      int boisAtualizados = await DatabaseHelper.instance.transferirLoteEmMassa(
        _loteOrigemCtrl.text,
        novoLoteFinal,
        _pastoDestinoCtrl.text,
      );

      print("Sucesso! $boisAtualizados bois foram transferidos de lote/pasto.");
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Movimentação registada com sucesso!'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Movimentação'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CARD 1: SERVIÇO ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment),
                          SizedBox(width: 8),
                          Text(
                            'SERVIÇO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Data: ${_data.day}/${_data.month}/${_data.year}",
                        ),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final pick = await showDatePicker(
                            context: context,
                            initialDate: _data,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pick != null) setState(() => _data = pick);
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                        ),
                        value: _tipoServico,
                        items: ['Manejo', 'Transferência']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _tipoServico = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- CARD 2: ORIGEM E DESTINO ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.swap_horiz),
                          SizedBox(width: 8),
                          Text(
                            'ORIGEM E DESTINO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pastoOrigemCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Pasto Origem',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _pastoDestinoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Pasto Destino',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _loteOrigemCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Lote Origem',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _loteDestinoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Novo Lote (Opcional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- CARD 3: DETALHES ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 8),
                          Text(
                            'DETALHES',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      TextFormField(
                        controller: _quantidadeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Contagem (Qtd Animais)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _responsavelCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Responsável',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _obsCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Observações de Nutrição / Gerais',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _salvarMovimentacao,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "SALVAR MOVIMENTAÇÃO",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
