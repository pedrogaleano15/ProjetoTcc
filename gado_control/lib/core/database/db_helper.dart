import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Padrão Singleton: Garante apenas uma instância do banco de dados rodando
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gado_control.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Habilita o uso de Foreign Keys (Chaves Estrangeiras) no SQLite
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Criação das Tabelas
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullType = 'TEXT'; // Pode ser vazio
    const realType = 'REAL NOT NULL'; // Números com vírgula
    const intType = 'INTEGER NOT NULL';

    // 1. Tabela Principal do Animal
    await db.execute('''
      CREATE TABLE animais (
        id $idType,
        identificacao $textType UNIQUE, 
        sexo $textType,
        raca $textType,
        mae_identificacao $textNullType,
        data_nascimento $textType,
        peso_nascimento $realType
      )
    ''');

    // 2. Tabela de Desmame
    await db.execute('''
      CREATE TABLE evento_desmame (
        id $idType,
        animal_id $intType,
        data_desmame $textType,
        peso_desmame $realType,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabela de Inseminação
    await db.execute('''
      CREATE TABLE evento_inseminacao (
        id $idType,
        animal_id $intType,
        data_inseminacao $textType,
        lote $textType,
        peso_momento $realType,
        condicao_corporal $textType,
        categoria $textType,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 4. Tabela de Morte
    await db.execute('''
      CREATE TABLE evento_morte (
        id $idType,
        animal_id $intType,
        data_morte $textType,
        local $textType,
        causa $textType,
        idade_meses $intType,
        FOREIGN KEY (animal_id) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');
  }

  // Fecha o banco de dados
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Função para Inserir um novo animal
  Future<int> inserirAnimal(Map<String, dynamic> animal) async {
    Database db = await instance.database;
    return await db.insert('animais', animal);
  }

  // Função para Listar todos os animais
  Future<List<Map<String, dynamic>>> listarAnimais() async {
    Database db = await instance.database;
    return await db.query(
      'animais',
      orderBy: 'id DESC',
    ); // Traz os mais recentes primeiro
  }
}
