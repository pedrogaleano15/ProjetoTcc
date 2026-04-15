import 'package:sqflite/sqflite.dart';
import '../core/database/database_core.dart';
import '../models/animal.dart';

class GadoRepository {
  GadoRepository._privateConstructor();
  static final GadoRepository instance = GadoRepository._privateConstructor();

  Future<Database> get _db async => await DatabaseCore.instance.database;

  // === MÉTODOS DE INSERÇÃO (CREATE) ===

  // Recebe um objeto Animal tipado em vez de um Map genérico.
  // O .toMap() converte para o formato que o SQLite espera.
  Future<int> inserirAnimal(Animal animal) async {
    final db = await _db;
    final dados = animal.toMap();
    // Garante que o peso atual começa igual ao peso de nascimento
    dados['peso_atual'] = dados['peso_nascimento'];
    dados['status'] = 'Ativo';
    return db.insert('animais', dados);
  }

  Future<int> inserirPesagem(Map<String, dynamic> row) async {
    Database db = await _db;
    await atualizarPesoAnimal(row['animal_id'], row['peso_atual']);
    return await db.insert('pesagens', row);
  }

  Future<int> inserirVacina(Map<String, dynamic> row) async =>
      await (await _db).insert('vacinas', row);
  Future<int> inserirSaude(Map<String, dynamic> row) async =>
      await (await _db).insert('historico_saude', row);
  Future<int> inserirReproducao(Map<String, dynamic> row) async =>
      await (await _db).insert('reproducao', row);
  Future<int> inserirDesmame(Map<String, dynamic> row) async =>
      await (await _db).insert('desmame', row);
  Future<int> inserirBaixa(Map<String, dynamic> row) async =>
      await (await _db).insert('baixas', row);
  Future<int> inserirMovimentacao(Map<String, dynamic> row) async =>
      await (await _db).insert('movimentacoes', row);

  // === MÉTODOS DE ATUALIZAÇÃO (UPDATE) ===
  Future<int> transferirLoteEmMassa(
    String loteOriginal,
    String novoLote,
    String novoPasto,
  ) async {
    return await (await _db).update(
      'animais',
      {'lote': novoLote, 'pasto': novoPasto},
      where: 'lote = ? AND status = ?',
      whereArgs: [loteOriginal, 'Ativo'],
    );
  }

  Future<int> atualizarLocalizacaoAnimal(
    String brinco,
    String novoPasto,
    String novoLote,
  ) async {
    return await (await _db).update(
      'animais',
      {'pasto': novoPasto, 'lote': novoLote},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  Future<int> atualizarStatusSaude(int idRegistro, String novoStatus) async {
    return await (await _db).update(
      'historico_saude',
      {'status': novoStatus},
      where: 'id = ?',
      whereArgs: [idRegistro],
    );
  }

  Future<int> atualizarStatusReproducao(
    int idRegistro,
    String novoStatus,
  ) async {
    return await (await _db).update(
      'reproducao',
      {'status': novoStatus},
      where: 'id = ?',
      whereArgs: [idRegistro],
    );
  }

  Future<int> atualizarStatusAnimal(String brinco, String novoStatus) async {
    return await (await _db).update(
      'animais',
      {'status': novoStatus},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  Future<int> atualizarLoteAnimal(String brinco, String novoLote) async {
    return await (await _db).update(
      'animais',
      {'lote': novoLote},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  Future<int> atualizarPesoAnimal(String brinco, double novoPeso) async {
    return await (await _db).update(
      'animais',
      {'peso_atual': novoPeso},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  // === MÉTODOS DE LISTAGEM (READ) ===

  // Retorna um Animal tipado em vez de Map. Se não encontrar, retorna null.
  Future<Animal?> obterAnimal(String brinco) async {
    final resultado = await (await _db).query(
      'animais',
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
    if (resultado.isEmpty) return null;
    return Animal.fromMap(resultado.first);
  }

  // Lista todos os animais como objetos Animal tipados.
  // A query traz o status_reproducao mais recente junto.
  Future<List<Animal>> listarAnimais() async {
    final resultados = await (await _db).rawQuery('''
      SELECT a.*, (SELECT status FROM reproducao r WHERE r.animal_id = a.identificacao ORDER BY data_inseminacao DESC LIMIT 1) as status_reproducao
      FROM animais a ORDER BY a.identificacao ASC
    ''');
    return resultados.map((row) => Animal.fromMap(row)).toList();
  }

  Future<List<Map<String, dynamic>>> listarPesagens(String id) async =>
      await (await _db).query(
        'pesagens',
        where: 'animal_id = ?',
        whereArgs: [id],
        orderBy: 'data_pesagem DESC',
      );
  Future<List<Map<String, dynamic>>> listarVacinasPorAnimal(String id) async =>
      await (await _db).query(
        'vacinas',
        where: 'animal_id = ?',
        whereArgs: [id],
        orderBy: 'data_aplicacao DESC',
      );
  Future<List<Map<String, dynamic>>> listarHistoricoSaude(String id) async =>
      await (await _db).query(
        'historico_saude',
        where: 'animal_id = ?',
        whereArgs: [id],
        orderBy: 'data_diagnostico DESC',
      );
  Future<List<Map<String, dynamic>>> listarReproducao(String id) async =>
      await (await _db).query(
        'reproducao',
        where: 'animal_id = ?',
        whereArgs: [id],
        orderBy: 'data_inseminacao DESC',
      );
  Future<List<Map<String, dynamic>>> listarDesmame(String id) async =>
      await (await _db).query(
        'desmame',
        where: 'animal_id = ?',
        whereArgs: [id],
      );
  Future<List<Map<String, dynamic>>> listarBaixas(String id) async =>
      await (await _db).query(
        'baixas',
        where: 'animal_id = ?',
        whereArgs: [id],
      );
  Future<List<Map<String, dynamic>>> listarMovimentacoes() async =>
      await (await _db).query('movimentacoes', orderBy: 'id DESC');

  // === MÉTODOS DE EXTRAÇÃO DE DADOS CRUS (Para os Services) ===
  Future<List<Map<String, dynamic>>> buscarFemeasComIdadeEFalhas() async {
    return await (await _db).rawQuery('''
      SELECT a.*, 
        (SELECT status FROM reproducao r WHERE r.animal_id = a.identificacao ORDER BY data_inseminacao DESC LIMIT 1) as ultimo_status,
        (SELECT COUNT(*) FROM reproducao r WHERE r.animal_id = a.identificacao AND status IN ('Vazia', 'Aborto')) as total_falhas,
        ((julianday('now') - CASE WHEN a.data_nascimento LIKE '%/%/%' THEN julianday(substr(a.data_nascimento, 7, 4) || '-' || substr(a.data_nascimento, 4, 2) || '-' || substr(a.data_nascimento, 1, 2)) ELSE julianday(a.data_nascimento) END) / 30.44) as idade_meses
      FROM animais a WHERE a.status = 'Ativo' AND a.sexo = 'Fêmea'
    ''');
  }

  Future<List<Map<String, dynamic>>> buscarBezerrosParaDesmame() async {
    return await (await _db).rawQuery('''
      SELECT a.*, 
        ((julianday('now') - CASE WHEN a.data_nascimento LIKE '%/%/%' THEN julianday(substr(a.data_nascimento, 7, 4) || '-' || substr(a.data_nascimento, 4, 2) || '-' || substr(a.data_nascimento, 1, 2)) ELSE julianday(a.data_nascimento) END) / 30.44) as idade_meses
      FROM animais a
      WHERE a.status = 'Ativo' AND idade_meses >= 3.0 AND idade_meses <= 12.0
      AND NOT EXISTS (SELECT 1 FROM desmame d WHERE d.animal_id = a.identificacao)
      ORDER BY idade_meses DESC
    ''');
  }

  // ==========================================
  // MÉTODOS DE BI (DASHBOARDS ADMIN)
  // ==========================================
  Future<List<Map<String, dynamic>>> obterLotacaoPorPasto() async {
    return await (await _db).rawQuery('''
      SELECT COALESCE(pasto, 'Sem Pasto') as pasto_nome, COUNT(*) as quantidade 
      FROM animais 
      WHERE status = 'Ativo' 
      GROUP BY pasto 
      ORDER BY quantidade DESC
    ''');
  }

  // ==========================================
  // MÉTODOS DE VALIDAÇÃO DE NEGÓCIO
  // ==========================================
  Future<bool> temBezerroPendenteDesmame(String maeId) async {
    // Procura um animal ativo onde a mãe seja a vaca atual,
    // e que NÃO exista na tabela de desmame.
    final res = await (await _db).rawQuery(
      '''
      SELECT 1 FROM animais a
      WHERE a.mae_identificacao = ? AND a.status = 'Ativo'
      AND NOT EXISTS (SELECT 1 FROM desmame d WHERE d.animal_id = a.identificacao)
      LIMIT 1
    ''',
      [maeId],
    );

    return res
        .isNotEmpty; // Se encontrar algum, retorna TRUE (tem bezerro a mamar)
  }
}
