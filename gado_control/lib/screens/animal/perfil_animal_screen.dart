import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

import 'form_desmame.dart';
import 'form_morte.dart';
import '../saude_reproducao/form_pesagem.dart';
import '../saude_reproducao/form_doenca.dart';
import '../saude_reproducao/form_inseminacao.dart';
import '../saude_reproducao/form_vacinacao.dart';

class PerfilAnimalScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  const PerfilAnimalScreen({Key? key, required this.animal}) : super(key: key);

  @override
  _PerfilAnimalScreenState createState() => _PerfilAnimalScreenState();
}

class _PerfilAnimalScreenState extends State<PerfilAnimalScreen> {
  late Map<String, dynamic> _animalAtual;

  List<Map<String, dynamic>> _pesagens = [];
  List<Map<String, dynamic>> _historicoSaude = [];
  List<Map<String, dynamic>> _reproducao = [];
  List<Map<String, dynamic>> _vacinas = [];

  bool _jaDesmamou = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animalAtual = widget.animal;
    _carregarDados();
  }

  void _carregarDados() async {
    setState(() => _isLoading = true);

    final idBrinco = _animalAtual['identificacao'].toString();

    final animalAtualizado = await DatabaseHelper.instance.obterAnimal(
      idBrinco,
    );
    final pesagens = await DatabaseHelper.instance.listarPesagens(idBrinco);
    final saude = await DatabaseHelper.instance.listarHistoricoSaude(idBrinco);
    final repro = await DatabaseHelper.instance.listarReproducao(idBrinco);
    final desmames = await DatabaseHelper.instance.listarDesmame(idBrinco);
    final vacinas = await DatabaseHelper.instance.listarVacinasPorAnimal(
      idBrinco,
    );

    if (mounted) {
      setState(() {
        if (animalAtualizado != null) _animalAtual = animalAtualizado;
        _pesagens = pesagens;
        _historicoSaude = saude;
        _reproducao = repro;
        _vacinas = vacinas;
        _jaDesmamou = desmames.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  void _abrirForm(Widget formScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => formScreen),
    ).then((sucesso) {
      if (sucesso == true) _carregarDados();
    });
  }

  // ==================================================
  // JANELAS INTERATIVAS (MODAIS) PARA ATUALIZAR STATUS
  // ==================================================

  void _atualizarStatusSaude(int id, String statusAtual) {
    String novoStatus = statusAtual;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Status Clínico'),
        content: DropdownButtonFormField<String>(
          value: statusAtual,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            'Em Tratamento',
            'Curado',
            'Em Observação',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => novoStatus = v!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.atualizarStatusSaude(
                id,
                novoStatus,
              );
              if (!mounted) return;
              Navigator.pop(context);
              _carregarDados(); // Recarrega a tela!
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _moverAnimalIndividual() {
    final pastoCtrl = TextEditingController(text: _animalAtual['pasto'] ?? '');
    final loteCtrl = TextEditingController(text: _animalAtual['lote'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mover Animal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Atualize a localização exata deste animal:'),
            const SizedBox(height: 16),
            TextField(
              controller: pastoCtrl,
              decoration: const InputDecoration(
                labelText: 'Pasto Atual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: loteCtrl,
              decoration: const InputDecoration(
                labelText: 'Lote Atual',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Atualiza a ficha do animal
              await DatabaseHelper.instance.atualizarLocalizacaoAnimal(
                _animalAtual['identificacao'].toString(),
                pastoCtrl.text,
                loteCtrl.text,
              );

              // 2. A MÁGICA: Regista a ação na caderneta de movimentações!
              await DatabaseHelper.instance.inserirMovimentacao({
                'data_movimentacao': DateTime.now().toIso8601String(),
                'tipo_servico': 'Manejo Individual',
                'pasto_origem': _animalAtual['pasto'] ?? '-',
                'pasto_destino': pastoCtrl.text,
                'lote_original': _animalAtual['lote'] ?? '-',
                'novo_lote': loteCtrl.text,
                'quantidade_animais': 1,
                'responsavel': '-',
                'observacoes':
                    'Brinco: ${_animalAtual['identificacao']}', // Regista qual foi o boi
              });

              if (!mounted) return;
              Navigator.pop(context);
              _carregarDados(); // Recarrega o perfil com os novos dados
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Animal movido e registado no histórico!'),
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _atualizarStatusReproducao(int id, String statusAtual) {
    String novoStatus = statusAtual;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado do Toque'),
        content: DropdownButtonFormField<String>(
          value: statusAtual,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            'Aguardando Diagnóstico',
            'Prenhe',
            'Vazia',
            'Aborto',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => novoStatus = v!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.atualizarStatusReproducao(
                id,
                novoStatus,
              );
              if (!mounted) return;
              Navigator.pop(context);
              _carregarDados(); // Recarrega a tela!
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // ==================================================

  @override
  Widget build(BuildContext context) {
    final bool isMacho = _animalAtual['sexo'] == 'Macho';
    final bool isMorto = _animalAtual['status'] == 'Morto';
    final corPrincipal = isMorto
        ? Colors.grey[800]!
        : (isMacho ? Colors.blue[800]! : Colors.pink[800]!);

    return DefaultTabController(
      length: isMacho ? 3 : 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Brinco: ${_animalAtual['identificacao']}'),
          backgroundColor: corPrincipal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildCabecalho(corPrincipal, isMacho, isMorto),
            _buildAcoesRapidas(isFemea: !isMacho, isMorto: isMorto),
            Container(
              color: Colors.white,
              child: TabBar(
                isScrollable:
                    true, // Adicione isto para os textos não ficarem espremidos
                labelColor: corPrincipal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: corPrincipal,
                tabs: [
                  const Tab(icon: Icon(Icons.monitor_weight), text: "Pesagens"),
                  const Tab(icon: Icon(Icons.medical_services), text: "Saúde"),
                  const Tab(
                    icon: Icon(Icons.vaccines),
                    text: "Vacinas",
                  ), // <--- NOVA ABA
                  if (!isMacho)
                    const Tab(icon: Icon(Icons.favorite), text: "Reprodução"),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildAbaPesagens(),
                        _buildAbaSaude(),
                        _buildAbaVacinas(),
                        if (!isMacho) _buildAbaReproducao(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho(Color cor, bool isMacho, bool isMorto) {
    return Container(
      width: double.infinity,
      color: cor.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cor.withOpacity(0.2),
            child: Icon(
              isMorto ? Icons.warning : (isMacho ? Icons.male : Icons.female),
              size: 40,
              color: cor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _animalAtual['raca'] ?? 'Raça Desconhecida',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          Text(
            'Lote: ${_animalAtual['lote'] ?? '-'} | Peso Nasc: ${_animalAtual['peso_nascimento']}kg',
            style: TextStyle(color: Colors.grey[700]),
          ),
          if (isMorto)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'ANIMAL INATIVO (MORTO)',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          if (_jaDesmamou && !isMorto)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '✓ ANIMAL DESMAMADO',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAcoesRapidas({required bool isFemea, required bool isMorto}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),

            // ---> AQUI ESTÁ O NOVO BOTÃO DE MOVER! <---
            _buildBotaoAcao(
              Icons.drive_file_move,
              'Mover',
              Colors.teal,
              isMorto,
              _moverAnimalIndividual,
            ),
            _buildBotaoAcao(
              Icons.vaccines,
              'Vacinar',
              Colors.teal,
              isMorto,
              () => _abrirForm(FormVacinacaoScreen(animal: _animalAtual)),
            ),
            _buildBotaoAcao(
              Icons.scale,
              'Pesar',
              Colors.green,
              isMorto,
              () => _abrirForm(FormPesagemScreen(animal: _animalAtual)),
            ),
            _buildBotaoAcao(
              Icons.medical_services,
              'Saúde',
              Colors.red,
              isMorto,
              () => _abrirForm(FormDoencaScreen(animal: _animalAtual)),
            ),
            if (isFemea)
              _buildBotaoAcao(
                Icons.favorite,
                'Inseminar',
                Colors.pink,
                isMorto,
                () => _abrirForm(FormInseminacaoScreen(animal: _animalAtual)),
              ),
            _buildBotaoAcao(
              Icons.grass,
              'Desmame',
              Colors.orange,
              isMorto || _jaDesmamou,
              () => _abrirForm(FormDesmameScreen(animal: _animalAtual)),
            ),
            _buildBotaoAcao(
              Icons.warning,
              'Baixa',
              Colors.grey[800]!,
              isMorto,
              () => _abrirForm(FormMorteScreen(animal: _animalAtual)),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoAcao(
    IconData icone,
    String texto,
    Color cor,
    bool desativado,
    VoidCallback onTap,
  ) {
    final Color corFinal = desativado ? Colors.grey : cor;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: desativado ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: corFinal.withOpacity(0.15),
              child: Icon(icone, color: corFinal, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              texto,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: corFinal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbaVacinas() {
    if (_vacinas.isEmpty)
      return const Center(child: Text("Nenhuma vacina registada."));
    return ListView.builder(
      itemCount: _vacinas.length,
      itemBuilder: (context, index) {
        final vac = _vacinas[index];
        String data = vac['data_aplicacao'].toString().split('T').first;
        String reforco =
            vac['proxima_dose'] != null &&
                vac['proxima_dose'].toString().isNotEmpty
            ? vac['proxima_dose'].toString().split('T').first
            : 'Sem reforço agendado';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.vaccines, color: Colors.white),
            ),
            title: Text(
              vac['nome_vacina'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Data: $data\nReforço: $reforco'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildAbaPesagens() {
    if (_pesagens.isEmpty)
      return const Center(child: Text("Nenhuma pesagem registada."));
    return ListView.builder(
      itemCount: _pesagens.length,
      itemBuilder: (context, index) {
        final pes = _pesagens[index];
        String data = pes['data_pesagem'].toString().split('T').first;
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.monitor_weight, color: Colors.white),
          ),
          title: Text(
            '${pes['peso_atual']} kg',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text('Data: $data'),
          trailing: pes['gmd'] != null
              ? Text(
                  'GMD: ${pes['gmd'].toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.blueGrey),
                )
              : null,
        );
      },
    );
  }

  Widget _buildAbaSaude() {
    if (_historicoSaude.isEmpty)
      return const Center(child: Text("Nenhum histórico clínico."));
    return ListView.builder(
      itemCount: _historicoSaude.length,
      itemBuilder: (context, index) {
        final saude = _historicoSaude[index];
        String data = saude['data_diagnostico'].toString().split('T').first;
        bool isCurado = saude['status'] == 'Curado';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              isCurado ? Icons.check_circle : Icons.healing,
              color: isCurado ? Colors.green : Colors.orange,
              size: 30,
            ),
            title: Text(
              saude['diagnostico'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Data: $data\nStatus: ${saude['status']}'),
            trailing: const Icon(
              Icons.edit,
              color: Colors.grey,
              size: 20,
            ), // Ícone visual para indicar que é clicável
            isThreeLine: true,
            // A MAGIA DO CLIQUE!
            onTap: () => _atualizarStatusSaude(saude['id'], saude['status']),
          ),
        );
      },
    );
  }

  Widget _buildAbaReproducao() {
    if (_reproducao.isEmpty)
      return const Center(child: Text("Nenhum protocolo reprodutivo."));
    return ListView.builder(
      itemCount: _reproducao.length,
      itemBuilder: (context, index) {
        final repro = _reproducao[index];
        String data = repro['data_inseminacao'].toString().split('T').first;
        String parto = repro['previsao_parto'].toString().split('T').first;

        // Cores baseadas no status
        Color corIcone = Colors.pink;
        if (repro['status'] == 'Prenhe') corIcone = Colors.green;
        if (repro['status'] == 'Vazia') corIcone = Colors.red;
        if (repro['status'] == 'Aborto') corIcone = Colors.grey;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: corIcone,
              child: const Icon(Icons.child_friendly, color: Colors.white),
            ),
            title: Text(
              '${repro['tipo_reproducao']} - Touro: ${repro['touro_id']}',
            ),
            subtitle: Text(
              'Inseminação: $data\nPrevisão de Parto: $parto\nStatus: ${repro['status']}',
            ),
            trailing: const Icon(
              Icons.edit,
              color: Colors.grey,
              size: 20,
            ), // Ícone indicativo
            isThreeLine: true,
            // A MAGIA DO CLIQUE!
            onTap: () =>
                _atualizarStatusReproducao(repro['id'], repro['status']),
          ),
        );
      },
    );
  }
}
