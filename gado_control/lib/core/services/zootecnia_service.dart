import '../../repositories/gado_repository.dart';

class ZootecniaService {
  ZootecniaService._privateConstructor();
  static final ZootecniaService instance =
      ZootecniaService._privateConstructor();

  final GadoRepository _repository = GadoRepository.instance;

  // ==========================================
  // REGRAS VETERINÁRIAS (INSEMINAÇÃO E DESCARTE)
  // ==========================================
  // ==========================================
  // REGRAS VETERINÁRIAS (INSEMINAÇÃO E DESCARTE)
  // ==========================================
  Future<Map<String, List<Map<String, dynamic>>>>
  processarRegrasReprodutivas() async {
    final femeas = await _repository.buscarFemeasComIdadeEFalhas();

    List<Map<String, dynamic>> loteInseminacao = [];
    List<Map<String, dynamic>> loteDescarte = [];

    const double idadeMinimaEmMeses = 14.0;
    const int limiteFalhasParaRevisao =
        1; // 1ª Falha = Vai para Revisão/Descarte

    for (var vaca in femeas) {
      double idade = vaca['idade_meses'] ?? 0.0;
      int falhas = vaca['total_falhas'] ?? 0;
      String? ultimoStatus = vaca['ultimo_status'];

      bool isNaoPrenhe =
          (ultimoStatus == null ||
          ultimoStatus == 'Vazia' ||
          ultimoStatus == 'Aborto');

      // 1. REGRA DE IDADE
      if (idade < idadeMinimaEmMeses) continue; // Muito nova, ignora.

      // 2. REGRA DO BEZERRO AO PÉ (Só verifica se ela não estiver prenhe)
      if (isNaoPrenhe) {
        bool temBezerro = await _repository.temBezerroPendenteDesmame(
          vaca['identificacao'].toString(),
        );

        if (temBezerro) {
          continue; // PULA! Ela tem bezerro a mamar, o corpo não está pronto para nova IA.
        }

        // 3. REGRA DO DESCARTE / VACA CHANCE
        if (falhas >= limiteFalhasParaRevisao) {
          loteDescarte.add(
            vaca,
          ); // Vai para a lista onde o Peão decide se vende, abate ou dá Nova Chance
        } else {
          loteInseminacao.add(vaca); // Virgens ou vacas com histórico limpo
        }
      }
    }
    return {'aptas': loteInseminacao, 'descarte': loteDescarte};
  }

  // ==========================================
  // REGRA DO DESMAME
  // ==========================================
  Future<List<Map<String, dynamic>>> listarBezerrosParaDesmame() async {
    return await _repository.buscarBezerrosParaDesmame();
  }

  // ==========================================
  // DASHBOARDS (CÁLCULOS PARA GRÁFICOS)
  // ==========================================

  // Delegação ao repositório via service — a tela não precisa saber de onde vêm os dados
  Future<List<Map<String, dynamic>>> obterLotacaoPorPasto() async {
    return _repository.obterLotacaoPorPasto();
  }

  Future<Map<String, int>> obterResumoPorSexo() async {
    final todosAnimais = await _repository.listarAnimais();
    int machos = 0;
    int femeas = 0;

    // Agora 'a' é um Objeto Animal, usamos o ponto (.)
    for (var a in todosAnimais) {
      if (a.status == 'Ativo') {
        if (a.sexo == 'Macho') machos++;
        if (a.sexo == 'Fêmea') femeas++;
      }
    }
    return {'Machos': machos, 'Fêmeas': femeas, 'Total': machos + femeas};
  }

  Future<Map<String, int>> obterEstatisticaReproducao() async {
    final todosAnimais = await _repository.listarAnimais();
    Map<String, int> stats = {
      'Prenhe': 0,
      'Vazia': 0,
      'Aguardando Diagnóstico': 0,
      'Aborto': 0,
    };

    // Agora 'a' é um Objeto Animal, usamos o ponto (.) e o nome exato da classe
    for (var a in todosAnimais) {
      if (a.status == 'Ativo' && a.statusReproducao != null) {
        String status = a.statusReproducao!;
        if (stats.containsKey(status)) {
          stats[status] = stats[status]! + 1;
        }
      }
    }
    return stats;
  }

  Map<String, dynamic> classificarAnimal(String? dataNascString, String? sexo) {
    if (dataNascString == null || dataNascString.isEmpty) {
      return {
        'meses': 0,
        'idade_texto': 'Idade Desconhecida',
        'categoria': 'Animal',
      };
    }

    DateTime dataNasc;
    try {
      if (dataNascString.contains('/')) {
        // "partes" é mais legível que uma variável de letra única
        final partes = dataNascString.split(' ')[0].split('/');
        dataNasc = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
      } else {
        dataNasc = DateTime.parse(dataNascString);
      }
    } catch (e) {
      return {
        'meses': 0,
        'idade_texto': 'Data Inválida',
        'categoria': 'Animal',
      };
    }

    int dias = DateTime.now().difference(dataNasc).inDays;
    int meses = (dias / 30.44).floor();

    // Formata a idade para ficar bonito (Ex: "1a 2m" ou "8 meses")
    String idadeStr = meses >= 12
        ? '${(meses / 12).floor()}a ${meses % 12}m'
        : '$meses meses';

    // Regra Zootécnica Simplificada
    String categoria = '';
    if (sexo == 'Macho') {
      if (meses <= 10)
        categoria = 'Bezerro';
      else if (meses <= 24)
        categoria = 'Garrote';
      else
        categoria = 'Touro / Boi';
    } else {
      if (meses <= 10)
        categoria = 'Bezerra';
      else if (meses <= 36)
        categoria = 'Novilha';
      else
        categoria = 'Vaca / Matriz';
    }

    return {'meses': meses, 'idade_texto': idadeStr, 'categoria': categoria};
  }
}
