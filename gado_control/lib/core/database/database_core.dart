import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseCore {
  static const _databaseName = "GadoControlDB.db";
  static const _databaseVersion = 12;

  // Padrão Singleton
  DatabaseCore._privateConstructor();
  static final DatabaseCore instance = DatabaseCore._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
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
        peso_nascimento REAL, peso_atual REAL,
        lote TEXT, pasto TEXT, 
        carimbo TEXT, status TEXT DEFAULT 'Ativo'
      )
    ''');
    await db.execute('''
      CREATE TABLE movimentacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        data_movimentacao TEXT NOT NULL,
        tipo_servico TEXT NOT NULL, 
        pasto_origem TEXT, pasto_destino TEXT,
        lote_original TEXT, 
        novo_lote TEXT, quantidade_animais INTEGER,
        responsavel TEXT, observacoes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE pesagens (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        animal_id TEXT NOT NULL, 
        data_pesagem TEXT NOT NULL, 
        peso_anterior REAL, peso_atual REAL NOT NULL,
        gmd REAL, score_corporal INTEGER,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE vacinas (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        animal_id TEXT NOT NULL,
        nome_vacina TEXT NOT NULL, data_aplicacao TEXT, proxima_dose TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE historico_saude (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        animal_id TEXT NOT NULL, 
        data_diagnostico TEXT NOT NULL, 
        diagnostico TEXT NOT NULL, sintomas TEXT,
        tratamento TEXT, data_fim_tratamento TEXT, 
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
        touro_id TEXT NOT NULL, inseminador TEXT, 
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
        peso_ajustado_205 REAL, lote_destino TEXT, 
        observacoes TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE baixas (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        animal_id TEXT NOT NULL,
        data_baixa TEXT NOT NULL, causa TEXT NOT NULL, 
        observacoes TEXT,
        FOREIGN KEY (animal_id) REFERENCES animais (identificacao) ON DELETE CASCADE
      )
    ''');
  }

  // Migrações incrementais: cada bloco "if" roda apenas uma vez,
  // quando o usuário passa por aquela versão. Os dados nunca são apagados.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Exemplo: se no futuro você adicionar uma coluna "foto_path" na versão 13:
    // if (oldVersion < 13) {
    //   await db.execute(
    //     "ALTER TABLE animais ADD COLUMN foto_path TEXT",
    //   );
    // }
    //
    // Exemplo: versão 14 adiciona índice para buscas mais rápidas:
    // if (oldVersion < 14) {
    //   await db.execute(
    //     "CREATE INDEX IF NOT EXISTS idx_animais_lote ON animais (lote)",
    //   );
    // }
  }
}
