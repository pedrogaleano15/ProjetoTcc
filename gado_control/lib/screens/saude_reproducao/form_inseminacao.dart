import 'package:flutter/material.dart';
import '../../repositories/gado_repository.dart';
import '../../core/services/zootecnia_service.dart';
import '../../models/animal.dart';

class FormInseminacaoScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  // NOVA CHAVE DE ACESSO: Por padrão é falsa (aplica todas as regras estritas)
  final bool isVacaChance;

  const FormInseminacaoScreen({
    Key? key,
    required this.animal,
    this.isVacaChance = false,
  }) : super(key: key);

  @override
  _FormInseminacaoScreenState createState() => _FormInseminacaoScreenState();
}

class _FormInseminacaoScreenState extends State<FormInseminacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inseminadorController = TextEditingController();
  final _palhetaExternaController = TextEditingController();

  String _tipoReproducao = 'Inseminação Artificial (IA)';
  DateTime _dataServico = DateTime.now();

  bool _usarTouroDoRebanho = true;
  List<Animal> _tourosDisponiveis = [];
  String? _touroSelecionado;
  bool _carregandoTouros = true;

  // === CONTROLO DE BLOQUEIOS DA INTERFACE ===
  bool _isBloqueado = false;
  String _mensagemBloqueio = '';

  @override
  void initState() {
    super.initState();
    _buscarTourosDaFazenda();
    _verificarBloqueiosInteligentes();
  }

  void _verificarBloqueiosInteligentes() async {
    final idStr = widget.animal['identificacao'].toString();

    // 1. Verificação de Idade Mínima
    String dataNascString = widget.animal['data_nascimento'] ?? '';
    DateTime dataNasc = DateTime.now();
    if (dataNascString.isNotEmpty) {
      if (dataNascString.contains('/')) {
        List<String> partes = dataNascString.split(' ')[0].split('/');
        dataNasc = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
      } else {
        dataNasc = DateTime.tryParse(dataNascString) ?? DateTime.now();
      }
    }
    double idadeMeses = DateTime.now().difference(dataNasc).inDays / 30.44;

    if (idadeMeses < 14.0) {
      _ativarBloqueio(
        'Esta fêmea tem apenas ${idadeMeses.toInt()} meses. A idade mínima para IA é 14 meses.',
      );
      return;
    }

    // 2. Verificação de Status Atual (Evita inseminar vaca já prenhe)
    final historicoRepro = await GadoRepository.instance.listarReproducao(
      idStr,
    );
    if (historicoRepro.isNotEmpty) {
      String status = historicoRepro.first['status'];
      if (status == 'Prenhe' || status == 'Aguardando Diagnóstico') {
        _ativarBloqueio(
          'Ação Bloqueada: Esta matriz já se encontra no status "$status".',
        );
        return;
      }
    }

    // 3. Verificação de Bezerro ao Pé
    bool amamentando = await GadoRepository.instance.temBezerroPendenteDesmame(
      idStr,
    );
    if (amamentando) {
      _ativarBloqueio(
        'Ação Bloqueada: Esta matriz possui um bezerro ao pé. Registe o desmame do filhote antes de iniciar um novo protocolo reprodutivo.',
      );
      return;
    }

    // 4. Verificação de Falhas (A Regra da Revisão)
    // Se NÃO for uma Vaca Chance explícita, aplicamos o bloqueio de falhas!
    if (!widget.isVacaChance) {
      int contagemFalhas = historicoRepro
          .where((r) => r['status'] == 'Vazia' || r['status'] == 'Aborto')
          .length;
      if (contagemFalhas >= 1) {
        _ativarBloqueio(
          'VACA EM REVISÃO!\nEla falhou no último protocolo. Para lhe dar uma nova chance, aceda à aba "Revisão / Descarte".',
        );
        return;
      }
    }
  }

  void _ativarBloqueio(String motivo) {
    if (mounted) {
      setState(() {
        _isBloqueado = true;
        _mensagemBloqueio = motivo;
      });
    }
  }

  void _buscarTourosDaFazenda() async {
    final todosAnimais = await GadoRepository.instance.listarAnimais();
    setState(() {
      _tourosDisponiveis = todosAnimais.where((a) {
        if (a.sexo != 'Macho' || a.status == 'Morto') return false;
        final idadeMeses =
            ZootecniaService.instance.classificarAnimal(
              a.dataNascimento,
              a.sexo,
            )['meses'] ??
            0;
        return idadeMeses >= 14;
      }).toList();
      _carregandoTouros = false;
    });
  }

  void _salvar() async {
    if (_isBloqueado) return; // Segurança extra
    if (!_formKey.currentState!.validate()) return;

    String idTouroFinal = '';
    if (_usarTouroDoRebanho) {
      if (_touroSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selecione um Touro da fazenda ou mude para Sêmen Externo.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      idTouroFinal = _touroSelecionado!;
    } else {
      if (_palhetaExternaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preencha a identificação da palheta externa.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      idTouroFinal = _palhetaExternaController.text;
    }

    DateTime previsaoParto = _dataServico.add(const Duration(days: 285));
    final dados = {
      'animal_id': widget.animal['identificacao'].toString(),
      'data_inseminacao': _dataServico.toIso8601String(),
      'tipo_reproducao': _tipoReproducao,
      'touro_id': idTouroFinal,
      'inseminador': _inseminadorController.text,
      'previsao_parto': previsaoParto.toIso8601String(),
      'status': 'Aguardando Diagnóstico',
    };

    await GadoRepository.instance.inserirReproducao(dados);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Serviço registado com sucesso!'),
        backgroundColor: Colors.pink,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inseminar: ${widget.animal['identificacao']}'),
        backgroundColor: Colors.pink[800],
        foregroundColor: Colors.white,
      ),
      body: _carregandoTouros
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // === AVISO DE BLOQUEIO GIGANTE ===
                    if (_isBloqueado)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[800]!, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red[800], size: 40),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _mensagemBloqueio,
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      title: Text(
                        "Data do Serviço: ${_dataServico.day}/${_dataServico.month}/${_dataServico.year}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _isBloqueado
                          ? null
                          : () async {
                              // Se bloqueado, nem a data abre
                              final p = await showDatePicker(
                                context: context,
                                initialDate: _dataServico,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (p != null) setState(() => _dataServico = p);
                            },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Serviço',
                        border: OutlineInputBorder(),
                      ),
                      value: _tipoReproducao,
                      items:
                          [
                                'Inseminação Artificial (IA)',
                                'Monta Natural (Touro)',
                              ]
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: _isBloqueado
                          ? null
                          : (v) => setState(() => _tipoReproducao = v!),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.pink[200]!),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Origem do Reprodutor",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Sêmen Externo'),
                              Switch(
                                value: _usarTouroDoRebanho,
                                activeColor: Colors.pink,
                                onChanged: _isBloqueado
                                    ? null
                                    : (val) => setState(
                                        () => _usarTouroDoRebanho = val,
                                      ),
                              ),
                              const Text('Touro da Fazenda'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (_usarTouroDoRebanho)
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Selecione o Touro',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.male),
                              ),
                              value: _touroSelecionado,
                              items: _tourosDisponiveis
                                  .map(
                                    (touro) => DropdownMenuItem(
                                      value: touro.identificacao,
                                      child: Text(
                                        'Brinco: ${touro.identificacao} (${touro.raca ?? 'Mestiço'})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isBloqueado
                                  ? null
                                  : (v) =>
                                        setState(() => _touroSelecionado = v),
                              hint: Text(
                                _tourosDisponiveis.isEmpty
                                    ? 'Nenhum touro adulto ativo'
                                    : 'Escolha um macho',
                              ),
                            )
                          else
                            TextFormField(
                              controller: _palhetaExternaController,
                              readOnly: _isBloqueado,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText:
                                    'Identificação da Palheta / Touro Externo',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.science),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _inseminadorController,
                      readOnly: _isBloqueado,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Inseminador (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _isBloqueado ? null : _salvar,
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "REGISTAR SERVIÇO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isBloqueado
                            ? Colors.grey
                            : Colors.pink[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
