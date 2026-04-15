import 'package:flutter/material.dart';
import 'package:gado_control/core/services/zootecnia_service.dart';
import '../../repositories/gado_repository.dart';
import '../animal/perfil_animal_screen.dart';
import '../../shared/widgets/card_animal_list_title.dart';

class MenuManejoScreen extends StatefulWidget {
  final String modoLista;
  const MenuManejoScreen({Key? key, this.modoLista = 'Completo'})
    : super(key: key);
  @override
  _MenuManejoScreenState createState() => _MenuManejoScreenState();
}

class _MenuManejoScreenState extends State<MenuManejoScreen> {
  List<Map<String, dynamic>> _todosAnimais = [];
  List<Map<String, dynamic>> _animaisFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _pesquisaController = TextEditingController();
  List<String> _lotesDisponiveis = ['Todos os Lotes'];
  String _loteSelecionado = 'Todos os Lotes';

  @override
  void initState() {
    super.initState();
    _carregarAnimais();
  }

  Future<void> _carregarAnimais() async {
    List<Map<String, dynamic>> data = [];

    if (widget.modoLista == 'Inseminacao') {
      final analise = await ZootecniaService.instance
          .processarRegrasReprodutivas();
      data = analise['aptas'] ?? [];
    } else if (widget.modoLista == 'Descarte') {
      final analise = await ZootecniaService.instance
          .processarRegrasReprodutivas();
      data = analise['descarte'] ?? [];
    } else if (widget.modoLista == 'Desmame') {
      data = await ZootecniaService.instance.listarBezerrosParaDesmame();
    } else {
      // Recebemos a lista de Objects Animal e convertemos para Maps para a UI
      data = (await GadoRepository.instance.listarAnimais())
          .map((a) => a.toMap())
          .toList();
    }

    setState(() {
      _todosAnimais = data;
      _animaisFiltrados = data;
      _isLoading = false;
      Set<String> lotesUnicos = {'Todos os Lotes'};
      for (var a in data) {
        if (a['lote'] != null && a['lote'].toString().trim().isNotEmpty) {
          lotesUnicos.add(a['lote'].toString().trim());
        }
      }
      _lotesDisponiveis = lotesUnicos.toList();
      _loteSelecionado = 'Todos os Lotes';
    });
  }

  void _filtrarPorLote(String? lote) {
    setState(() {
      _loteSelecionado = lote!;
      if (_loteSelecionado == 'Todos os Lotes') {
        _animaisFiltrados = _todosAnimais;
      } else {
        _animaisFiltrados = _todosAnimais
            .where((a) => a['lote'].toString().trim() == _loteSelecionado)
            .toList();
      }
      if (_pesquisaController.text.isNotEmpty)
        _filtrarLista(_pesquisaController.text);
    });
  }

  void _filtrarLista(String termo) {
    if (termo.isEmpty) {
      _filtrarPorLote(_loteSelecionado);
      return;
    }
    setState(() {
      List<Map<String, dynamic>> baseLista =
          _loteSelecionado == 'Todos os Lotes'
          ? _todosAnimais
          : _todosAnimais
                .where((a) => a['lote'].toString().trim() == _loteSelecionado)
                .toList();
      _animaisFiltrados = baseLista.where((animal) {
        return animal['identificacao'].toString().toLowerCase().contains(
          termo.toLowerCase(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String tituloAppBar = 'Rebanho Completo';
    Color corAppBar = Colors.green[800]!;

    if (widget.modoLista == 'Inseminacao') {
      tituloAppBar = 'Lote de Inseminação';
      corAppBar = Colors.pink[800]!;
    } else if (widget.modoLista == 'Descarte') {
      tituloAppBar = 'Lote de Descarte/Venda';
      corAppBar = Colors.red[900]!;
    } else if (widget.modoLista == 'Desmame') {
      tituloAppBar = 'Lote de Desmame';
      corAppBar = Colors.orange[800]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tituloAppBar),
        backgroundColor: corAppBar,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // Actions e Drawer foram REMOVIDOS para a tela ficar limpa!
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: corAppBar.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: corAppBar),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _lotesDisponiveis.contains(_loteSelecionado)
                          ? _loteSelecionado
                          : 'Todos os Lotes',
                      items: _lotesDisponiveis
                          .map(
                            (lote) => DropdownMenuItem(
                              value: lote,
                              child: Text(
                                lote,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _filtrarPorLote,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Procurar por Brinco',
                hintText: 'Digite o número do animal...',
                prefixIcon: Icon(Icons.search, color: corAppBar),
                suffixIcon: _pesquisaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _pesquisaController.clear();
                          _filtrarLista('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: corAppBar, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filtrarLista,
            ),
          ),
          Expanded(child: _buildCorpoDaLista()),
        ],
      ),
    );
  }

  Widget _buildCorpoDaLista() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_animaisFiltrados.isEmpty)
      return const Center(child: Text('Nenhum animal encontrado.'));

    return RefreshIndicator(
      onRefresh: _carregarAnimais,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _animaisFiltrados.length,
        itemBuilder: (context, index) {
          final animal = _animaisFiltrados[index];
          return CardAnimalListTile(
            animal: animal,
            modoLista: widget.modoLista,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilAnimalScreen(animal: animal),
                ),
              ).then((_) => _carregarAnimais());
            },
          );
        },
      ),
    );
  }
}
