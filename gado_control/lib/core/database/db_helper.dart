import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "GadoControlDB.db";
  // Versão 4: Adiciona peso_atual e corrige os REFERENCES
  static const _databaseVersion = 4;

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
    // 1. Tabela do Animal (ADICIONADA A COLUNA peso_atual)
    await db.execute('''
      CREATE TABLE animais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identificacao TEXT NOT NULL,
        sexo TEXT,
        raca TEXT,
        mae_identificacao TEXT,
        data_nascimento TEXT,
        peso_nascimento REAL,
        peso_atual REAL 
      )
    ''');

    // 2. Tabela de Pesagens
    await db.execute('''
      CREATE TABLE pesagens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        peso REAL,
        data_pesagem TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabela de Vacinas
    await db.execute('''
      CREATE TABLE vacinas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        nome_vacina TEXT NOT NULL,
        data_aplicacao TEXT,
        proxima_dose TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 4. Tabela de Doenças
    await db.execute('''
      CREATE TABLE doencas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        diagnostico TEXT NOT NULL,
        data_diagnostico TEXT,
        tratamento_aplicado TEXT,
        status_cura TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 5. Tabela de Dietas
    await db.execute('''
      CREATE TABLE dietas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        tipo_racao TEXT,
        quantidade_kg_dia REAL,
        data_inicio TEXT,
        data_fim TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 6. Tabelas de Manejo (Corrigido para REFERENCES animais)
    await db.execute('''
        CREATE TABLE desmame (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_id INTEGER,
          data_desmame TEXT,
          peso_desmame REAL,
          FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
        )
      ''');

    await db.execute('''
        CREATE TABLE inseminacao (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_id INTEGER,
          data_inseminacao TEXT,
          lote TEXT,
          peso_momento REAL,
          condicao_corporal TEXT,
          categoria TEXT,
          FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
        )
      ''');

    await db.execute('''
        CREATE TABLE morte (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_id INTEGER,
          data_morte TEXT,
          local TEXT,
          causa TEXT,
          idade_meses INTEGER,
          FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
        )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS pesagens");
    await db.execute("DROP TABLE IF EXISTS vacinas");
    await db.execute("DROP TABLE IF EXISTS doencas");
    await db.execute("DROP TABLE IF EXISTS dietas");
    await db.execute("DROP TABLE IF EXISTS desmame");
    await db.execute("DROP TABLE IF EXISTS inseminacao");
    await db.execute("DROP TABLE IF EXISTS morte");
    await db.execute("DROP TABLE IF EXISTS animais");
    await _onCreate(db, newVersion);
  }

  // ==========================================
  // FUNÇÕES DE COMUNICAÇÃO (CRUD)
  // ==========================================

  Future<int> inserirAnimal(Map<String, dynamic> row) async {
    Database db = await instance.database;
    // Lógica: Ao nascer, o peso atual é igual ao peso de nascimento!
    row['peso_atual'] = row['peso_nascimento'];
    return await db.insert('animais', row);
  }

  Future<List<Map<String, dynamic>>> listarAnimais() async {
    Database db = await instance.database;
    return await db.query('animais');
  }

  // --- A MÁGICA DO PESO: ATUALIZA A FICHA DO ANIMAL ---
  Future<int> atualizarPesoAnimal(int id, double novoPeso) async {
    Database db = await instance.database;
    return await db.update(
      'animais',
      {'peso_atual': novoPeso},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- FUNÇÕES DA PESAGEM ---
  Future<int> inserirPesagem(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('pesagens', row);
  }

  Future<List<Map<String, dynamic>>> listarPesagensPorAnimal(
    int animalId,
  ) async {
    Database db = await instance.database;
    return await db.query(
      'pesagens',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'id DESC',
    );
  }

  // --- OUTRAS FUNÇÕES EXISTENTES ---
  Future<int> inserirDesmame(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('desmame', row);
  }

  Future<int> inserirInseminacao(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('inseminacao', row);
  }

  Future<int> inserirMorte(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('morte', row);
  }

  Future<int> inserirVacina(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('vacinas', row);
  }

  Future<List<Map<String, dynamic>>> listarVacinasPorAnimal(
    int animalId,
  ) async {
    Database db = await instance.database;
    return await db.query(
      'vacinas',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> listarDesmamesPorAnimal(
    int animalId,
  ) async {
    Database db = await instance.database;
    return await db.query(
      'desmame',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  Future<List<Map<String, dynamic>>> listarInseminacoesPorAnimal(
    int animalId,
  ) async {
    Database db = await instance.database;
    return await db.query(
      'inseminacao',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  Future<List<Map<String, dynamic>>> listarMortesPorAnimal(int animalId) async {
    Database db = await instance.database;
    return await db.query(
      'morte',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  // --- FUNÇÕES DE SAÚDE E DOENÇAS ---
  Future<int> inserirDoenca(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('doencas', row);
  }

  Future<List<Map<String, dynamic>>> listarDoencasPorAnimal(
    int animalId,
  ) async {
    Database db = await instance.database;
    return await db.query(
      'doencas',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'id DESC',
    );
  }

  // Função para dar "Alta" ao animal (Curar)
  Future<int> curarDoenca(int idDoenca, String tratamentoFinal) async {
    Database db = await instance.database;
    return await db.update(
      'doencas',
      {'status_cura': 'Curado', 'tratamento_aplicado': tratamentoFinal},
      where: 'id = ?',
      whereArgs: [idDoenca],
    );
  }
}
