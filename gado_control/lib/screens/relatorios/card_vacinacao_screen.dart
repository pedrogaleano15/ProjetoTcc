import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

// Se você tiver um modelo de Vacina, mantenha o import.
// Se não, podemos usar Map como fizemos nos outros.
class Vacina {
  final String nome;
  final String data;
  final String proximaDose;

  Vacina({required this.nome, required this.data, required this.proximaDose});

  factory Vacina.fromMap(Map<String, dynamic> map) {
    return Vacina(
      nome: map['nome_vacina'] ?? 'Vacina s/ nome',
      data: map['data_aplicacao'] ?? '--/--/--',
      proximaDose: map['proxima_dose'] ?? 'Não agendada',
    );
  }
}

class CartaoVacinacaoScreen extends StatefulWidget {
  // CORREÇÃO: Passamos o animal inteiro para ter acesso ao ID e ao Nome/Brinco
  final Map<String, dynamic> animal;

  const CartaoVacinacaoScreen({Key? key, required this.animal})
    : super(key: key);

  @override
  _CartaoVacinacaoScreenState createState() => _CartaoVacinacaoScreenState();
}

class _CartaoVacinacaoScreenState extends State<CartaoVacinacaoScreen> {
  List<Vacina> vacinas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarVacinas();
  }

  Future<void> _carregarVacinas() async {
    setState(() => isLoading = true);

    // CORREÇÃO: Pegamos o identificacao (Brinco) do widget.animal
    final String brinco = widget.animal['identificacao'].toString();

    final dados = await DatabaseHelper.instance.listarVacinasPorAnimal(brinco);

    setState(() {
      vacinas = dados.map((item) => Vacina.fromMap(item)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cartão de Vacinas: ${widget.animal['identificacao']}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vacinas.isEmpty
          ? _buildSemVacinas()
          : _buildListaVacinas(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Aqui você abriria o formulário de aplicação de vacina
          // _abrirFormVacina();
        },
      ),
    );
  }

  Widget _buildSemVacinas() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vaccines_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma vacina registada para este animal.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildListaVacinas() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vacinas.length,
      itemBuilder: (context, index) {
        final vacina = vacinas[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.check, color: Colors.white),
            ),
            title: Text(
              vacina.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Aplicada em: ${vacina.data}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Próxima Dose:',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  vacina.proximaDose,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
