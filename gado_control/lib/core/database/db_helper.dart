import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "GadoControlDB.db";
  static const _databaseVersion = 12;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE animais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identificacao TEXT NOT NULL UNIQUE,
        sexo TEXT,
        raca TEXT,
        mae_identificacao TEXT,
        observacao_mae TEXT, 
        data_nascimento TEXT,
        peso_nascimento REAL,
        peso_atual REAL,
        lote TEXT,
        pasto TEXT,
        carimbo TEXT,
        status TEXT DEFAULT 'Ativo'
      )
    ''');

    await db.execute('''
      CREATE TABLE movimentacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_movimentacao TEXT NOT NULL,
        tipo_servico TEXT NOT NULL,
        pasto_origem TEXT,
        pasto_destino TEXT,
        lote_original TEXT,
        novo_lote TEXT,
        quantidade_animais INTEGER,
        responsavel TEXT,
        observacoes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pesagens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id TEXT NOT NULL, 
        data_pesagem TEXT NOT NULL,
        peso_anterior REAL,
        peso_atual REAL NOT NULL,
        gmd REAL,
        score_corporal INTEGER,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE vacinas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id TEXT NOT NULL,
        nome_vacina TEXT NOT NULL,
        data_aplicacao TEXT,
        proxima_dose TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE historico_saude (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id TEXT NOT NULL, 
        data_diagnostico TEXT NOT NULL,
        diagnostico TEXT NOT NULL,
        sintomas TEXT,
        tratamento TEXT,
        data_fim_tratamento TEXT,
        status TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reproducao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id TEXT NOT NULL, 
        data_inseminacao TEXT NOT NULL,
        tipo_reproducao TEXT NOT NULL,
        touro_id TEXT NOT NULL,
        inseminador TEXT,
        previsao_parto TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE desmame (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id TEXT NOT NULL,
        data_desmame TEXT NOT NULL,
        peso_desmame REAL NOT NULL,
        peso_ajustado_205 REAL,
        lote_destino TEXT,
        observacoes TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE baixas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id TEXT NOT NULL,
        data_baixa TEXT NOT NULL,
        causa TEXT NOT NULL,
        observacoes TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS movimentacoes");
    await db.execute("DROP TABLE IF EXISTS pesagens");
    await db.execute("DROP TABLE IF EXISTS vacinas");
    await db.execute("DROP TABLE IF EXISTS historico_saude");
    await db.execute("DROP TABLE IF EXISTS reproducao");
    await db.execute("DROP TABLE IF EXISTS desmame");
    await db.execute("DROP TABLE IF EXISTS baixas");
    await db.execute("DROP TABLE IF EXISTS animais");
    await _onCreate(db, newVersion);
  }

  // ==========================================
  // MÉTODOS DE TRANSFERÊNCIA EM MASSA E ATUALIZAÇÕES
  // ==========================================

  Future<int> inserirMovimentacao(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('movimentacoes', row);
  }

  Future<int> transferirLoteEmMassa(
    String loteOriginal,
    String novoLote,
    String novoPasto,
  ) async {
    Database db = await instance.database;
    return await db.update(
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
    Database db = await instance.database;
    return await db.update(
      'animais',
      {'pasto': novoPasto, 'lote': novoLote},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  Future<int> atualizarStatusSaude(int idRegistro, String novoStatus) async {
    Database db = await instance.database;
    return await db.update(
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
    Database db = await instance.database;
    return await db.update(
      'reproducao',
      {'status': novoStatus},
      where: 'id = ?',
      whereArgs: [idRegistro],
    );
  }

  Future<int> atualizarStatusAnimal(String brinco, String novoStatus) async {
    Database db = await instance.database;
    return await db.update(
      'animais',
      {'status': novoStatus},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  Future<int> atualizarLoteAnimal(String brinco, String novoLote) async {
    Database db = await instance.database;
    return await db.update(
      'animais',
      {'lote': novoLote},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  Future<int> atualizarPesoAnimal(String brinco, double novoPeso) async {
    Database db = await instance.database;
    return await db.update(
      'animais',
      {'peso_atual': novoPeso},
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
  }

  // ==========================================
  // MÉTODOS DE INSERÇÃO (CREATE)
  // ==========================================

  Future<int> inserirAnimal(Map<String, dynamic> row) async {
    Database db = await instance.database;
    row['peso_atual'] = row['peso_nascimento'];
    row['status'] = 'Ativo';
    return await db.insert('animais', row);
  }

  Future<int> inserirPesagem(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await atualizarPesoAnimal(row['animal_id'], row['peso_atual']);
    return await db.insert('pesagens', row);
  }

  Future<int> inserirVacina(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('vacinas', row);
  }

  Future<int> inserirSaude(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('historico_saude', row);
  }

  Future<int> inserirReproducao(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('reproducao', row);
  }

  Future<int> inserirDesmame(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('desmame', row);
  }

  Future<int> inserirBaixa(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('baixas', row);
  }

  // ==========================================
  // MÉTODOS DE LISTAGEM (READ) - SIMPLES
  // ==========================================

  Future<Map<String, dynamic>?> obterAnimal(String brinco) async {
    Database db = await instance.database;
    final resultado = await db.query(
      'animais',
      where: 'identificacao = ?',
      whereArgs: [brinco],
    );
    if (resultado.isNotEmpty) return resultado.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> listarAnimais() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT a.*, 
        (SELECT status FROM reproducao r 
         WHERE r.animal_id = a.identificacao 
         ORDER BY data_inseminacao DESC LIMIT 1) as status_reproducao
      FROM animais a
      ORDER BY a.identificacao ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> listarPesagens(String animalId) async {
    Database db = await instance.database;
    return await db.query(
      'pesagens',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'data_pesagem DESC',
    );
  }

  Future<List<Map<String, dynamic>>> listarVacinasPorAnimal(
    String animalId,
  ) async {
    Database db = await instance.database;
    return await db.query(
      'vacinas',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'data_aplicacao DESC',
    );
  }

  Future<List<Map<String, dynamic>>> listarHistoricoSaude(
    String animalId,
  ) async {
    Database db = await instance.database;
    return await db.query(
      'historico_saude',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'data_diagnostico DESC',
    );
  }

  Future<List<Map<String, dynamic>>> listarReproducao(String animalId) async {
    Database db = await instance.database;
    return await db.query(
      'reproducao',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'data_inseminacao DESC',
    );
  }

  Future<List<Map<String, dynamic>>> listarDesmame(String animalId) async {
    Database db = await instance.database;
    return await db.query(
      'desmame',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  Future<List<Map<String, dynamic>>> listarBaixas(String animalId) async {
    Database db = await instance.database;
    return await db.query(
      'baixas',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  Future<List<Map<String, dynamic>>> listarMovimentacoes() async {
    Database db = await instance.database;
    return await db.query('movimentacoes', orderBy: 'id DESC');
  }

  // ==========================================
  // MÉTODOS DE BI (DASHBOARDS ADMIN)
  // ==========================================
  Future<Map<String, int>> obterResumoPorSexo() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT sexo, COUNT(*) as total FROM animais WHERE status = 'Ativo' GROUP BY sexo",
    );
    int machos = 0;
    int femeas = 0;
    for (var row in result) {
      if (row['sexo'] == 'Macho') machos = row['total'] as int;
      if (row['sexo'] == 'Fêmea') femeas = row['total'] as int;
    }
    return {'Machos': machos, 'Fêmeas': femeas, 'Total': machos + femeas};
  }

  Future<List<Map<String, dynamic>>> obterLotacaoPorPasto() async {
    Database db = await instance.database;
    return await db.rawQuery(
      "SELECT COALESCE(pasto, 'Sem Pasto') as pasto_nome, COUNT(*) as quantidade FROM animais WHERE status = 'Ativo' GROUP BY pasto ORDER BY quantidade DESC",
    );
  }

  Future<Map<String, int>> obterEstatisticaReproducao() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT r1.status, COUNT(*) as total FROM reproducao r1
      INNER JOIN (SELECT animal_id, MAX(data_inseminacao) as max_data FROM reproducao GROUP BY animal_id) r2 
      ON r1.animal_id = r2.animal_id AND r1.data_inseminacao = r2.max_data GROUP BY r1.status
    ''');
    Map<String, int> stats = {
      'Prenhe': 0,
      'Vazia': 0,
      'Aguardando Diagnóstico': 0,
      'Aborto': 0,
    };
    for (var row in result) {
      if (stats.containsKey(row['status']))
        stats[row['status'] as String] = row['total'] as int;
    }
    return stats;
  }

  // ==========================================
  // LISTAS INTELIGENTES (REGRAS VETERINÁRIAS)
  // ==========================================
  Future<Map<String, List<Map<String, dynamic>>>>
  processarRegrasReprodutivas() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> femeas = await db.rawQuery('''
      SELECT a.*, 
        (SELECT status FROM reproducao r WHERE r.animal_id = a.identificacao ORDER BY data_inseminacao DESC LIMIT 1) as ultimo_status,
        (SELECT COUNT(*) FROM reproducao r WHERE r.animal_id = a.identificacao AND status IN ('Vazia', 'Aborto')) as total_falhas,
        ((julianday('now') - CASE WHEN a.data_nascimento LIKE '%/%/%' THEN julianday(substr(a.data_nascimento, 7, 4) || '-' || substr(a.data_nascimento, 4, 2) || '-' || substr(a.data_nascimento, 1, 2)) ELSE julianday(a.data_nascimento) END) / 30.44) as idade_meses
      FROM animais a WHERE a.status = 'Ativo' AND a.sexo = 'Fêmea'
    ''');

    List<Map<String, dynamic>> loteInseminacao = [];
    List<Map<String, dynamic>> loteDescarte = [];
    const double IDADE_MINIMA_MESES = 14.0;
    const int LIMITE_FALHAS = 2;

    for (var vaca in femeas) {
      double idade = vaca['idade_meses'] ?? 0.0;
      int falhas = vaca['total_falhas'] ?? 0;
      String? ultimoStatus = vaca['ultimo_status'];
      bool isNaoPrenhe =
          (ultimoStatus == null ||
          ultimoStatus == 'Vazia' ||
          ultimoStatus == 'Aborto');

      if (idade >= IDADE_MINIMA_MESES && isNaoPrenhe) {
        if (falhas >= LIMITE_FALHAS)
          loteDescarte.add(vaca);
        else
          loteInseminacao.add(vaca);
      }
    }
    return {'aptas': loteInseminacao, 'descarte': loteDescarte};
  }

  Future<List<Map<String, dynamic>>> listarBezerrosParaDesmame() async {
    Database db = await instance.database;
    // Traz qualquer animal vivo entre 3 e 12 meses que ainda não foi desmamado
    return await db.rawQuery('''
      SELECT a.*, 
        ((julianday('now') - CASE WHEN a.data_nascimento LIKE '%/%/%' THEN julianday(substr(a.data_nascimento, 7, 4) || '-' || substr(a.data_nascimento, 4, 2) || '-' || substr(a.data_nascimento, 1, 2)) ELSE julianday(a.data_nascimento) END) / 30.44) as idade_meses
      FROM animais a
      WHERE a.status = 'Ativo' 
      AND idade_meses >= 3.0 AND idade_meses <= 12.0
      AND NOT EXISTS (SELECT 1 FROM desmame d WHERE d.animal_id = a.identificacao)
      ORDER BY idade_meses DESC
    ''');
  }
}
