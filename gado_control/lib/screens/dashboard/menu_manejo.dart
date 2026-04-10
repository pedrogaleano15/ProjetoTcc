import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../animal/perfil_animal_screen.dart';
import '../../shared/widgets/card_animal_list_title.dart';
import '../../shared/widgets/barra_pesquisa_inteligente.dart';
import '../../shared/widgets/menu_lateral_manejo.dart';

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
  String _tipoPesquisa = 'Brinco';

  // === VARIÁVEIS DO FILTRO DE LOTE ===
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
      final analise = await DatabaseHelper.instance
          .processarRegrasReprodutivas();
      data = analise['aptas'] ?? [];
    } else if (widget.modoLista == 'Descarte') {
      final analise = await DatabaseHelper.instance
          .processarRegrasReprodutivas();
      data = analise['descarte'] ?? [];
    } else if (widget.modoLista == 'Desmame') {
      data = await DatabaseHelper.instance.listarBezerrosParaDesmame();
    } else {
      data = await DatabaseHelper.instance.listarAnimais();
    }

    setState(() {
      _todosAnimais = data;
      _animaisFiltrados = data;
      _isLoading = false;

      // === EXTRAIR OS LOTES EXISTENTES PARA O FILTRO ===
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

  // === FUNÇÃO DO FILTRO POR LOTE ===
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
      // Se houver texto na barra de pesquisa, aplica por cima do filtro de lote
      if (_pesquisaController.text.isNotEmpty) {
        _filtrarLista(_pesquisaController.text);
      }
    });
  }

  // === PESQUISA DE TEXTO ===
  void _filtrarLista(String termo) {
    if (termo.isEmpty) {
      // Se apagar o texto, volta a mostrar a lista filtrada apenas pelo Lote
      _filtrarPorLote(_loteSelecionado);
      return;
    }

    setState(() {
      // Pega a lista base (completa ou já filtrada pelo Lote)
      List<Map<String, dynamic>> baseLista =
          _loteSelecionado == 'Todos os Lotes'
          ? _todosAnimais
          : _todosAnimais
                .where((a) => a['lote'].toString().trim() == _loteSelecionado)
                .toList();

      _animaisFiltrados = baseLista.where((animal) {
        final termoBusca = termo.toLowerCase();
        final valorAlvo = _tipoPesquisa == 'Brinco'
            ? animal['identificacao'].toString().toLowerCase()
            : (animal['lote'] ?? '').toString().toLowerCase();
        return valorAlvo.contains(termoBusca);
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

        leading: widget.modoLista == 'Completo'
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

        actions: widget.modoLista == 'Completo'
            ? [
                PopupMenuButton<String>(
                  onSelected: (valor) {
                    if (valor == 'vacinas') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resumo de Vacinas em construção...'),
                        ),
                      );
                    } else if (valor == 'cronograma') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cronograma em construção...'),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'vacinas',
                      child: Text('Resumo de Vacinas'),
                    ),
                    const PopupMenuItem(
                      value: 'cronograma',
                      child: Text('Cronograma'),
                    ),
                  ],
                ),
              ]
            : null,
      ),

      drawer: widget.modoLista == 'Completo' ? const MenuLateralManejo() : null,

      body: Column(
        children: [
          // ==================================================
          // NOVO MENU SUSPENSO (DROPDOWN) DE FILTRO POR LOTE
          // ==================================================
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

          // ==================================================
          // BARRA DE PESQUISA TRADICIONAL
          // ==================================================
          BarraPesquisaInteligente(
            controller: _pesquisaController,
            tipoPesquisa: _tipoPesquisa,
            onSearch: _filtrarLista,
            onClear: () {
              _pesquisaController.clear();
              _filtrarLista('');
            },
            onTipoChanged: (novoTipo) => setState(() {
              _tipoPesquisa = novoTipo!;
              _filtrarLista(_pesquisaController.text);
            }),
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
