import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "GadoControlDB.db";
  static const _databaseVersion =
      3; // Versão 3 forçará o reset automático do banco

  // Singleton pattern (Padrão de projeto para usar a mesma conexão)
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
      onUpgrade: _onUpgrade, // Vai limpar o banco velho e aplicar a versão 3
    );
  }

  // ==========================================
  // A MÁGICA ACONTECE AQUI: Criação das tabelas
  // ==========================================
  Future _onCreate(Database db, int version) async {
    // 1. Tabela do Animal (AGORA COMPLETA E COM OS NOMES CERTOS)
    await db.execute('''
      CREATE TABLE animais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identificacao TEXT NOT NULL,
        sexo TEXT,
        raca TEXT,
        mae_identificacao TEXT,
        data_nascimento TEXT,
        peso_nascimento REAL
      )
    ''');

    // 2. Tabela de Pesagens (Gráfico)
    await db.execute('''
      CREATE TABLE pesagens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        peso REAL,
        data_pesagem TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabela de Vacinas (Saúde)
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

    // 4. Tabela de Doenças (Saúde)
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

    // 5. Tabela de Dietas (Nutrição)
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

    // 6. Tabelas de Manejo (Desmame, Inseminação, Morte)
    // Criação da tabela de Desmame
    await db.execute('''
        CREATE TABLE desmame (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_id INTEGER,
          data_desmame TEXT,
          peso_desmame REAL,
          FOREIGN KEY (animal_id) REFERENCES animal (id) ON DELETE CASCADE
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
          FOREIGN KEY (animal_id) REFERENCES animal (id) ON DELETE CASCADE
        )
      ''');

    // Criação da tabela de Morte
    await db.execute('''
        CREATE TABLE morte (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_id INTEGER,
          data_morte TEXT,
          local TEXT,
          causa TEXT,
          idade_meses INTEGER,
          FOREIGN KEY (animal_id) REFERENCES animal (id) ON DELETE CASCADE
        )
      ''');
  }

  // Função para lidar com a atualização do banco de dados na fase de testes
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Apaga as tabelas velhas (se existirem) para não dar conflito
    await db.execute("DROP TABLE IF EXISTS pesagens");
    await db.execute("DROP TABLE IF EXISTS vacinas");
    await db.execute("DROP TABLE IF EXISTS doencas");
    await db.execute("DROP TABLE IF EXISTS dietas");
    await db.execute("DROP TABLE IF EXISTS desmame");
    await db.execute("DROP TABLE IF EXISTS inseminacao");
    await db.execute("DROP TABLE IF EXISTS morte");
    await db.execute("DROP TABLE IF EXISTS animais");
    // Cria tudo limpinho e zerado
    await _onCreate(db, newVersion);
  }

  // ==========================================
  // FUNÇÕES DE COMUNICAÇÃO (CRUD)
  // ==========================================

  // Inserir Animal
  Future<int> inserirAnimal(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('animais', row);
  }

  // Listar Animais
  Future<List<Map<String, dynamic>>> listarAnimais() async {
    Database db = await instance.database;
    return await db.query('animais');
  }

  // Inserir Desmame
  Future<int> inserirDesmame(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('desmame', row);
  }

  // Inserir Inseminação
  Future<int> inserirInseminacao(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('inseminacao', row);
  }

  // Inserir Morte
  Future<int> inserirMorte(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('morte', row);
  }

  // Inserir Vacina
  Future<int> inserirVacina(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('vacinas', row);
  }

  // Listar Vacinas do Boi
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
  // --- FUNÇÕES DE LER O HISTÓRICO ---

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
}
