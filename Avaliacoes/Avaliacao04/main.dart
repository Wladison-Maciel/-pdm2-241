import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Aluno {
  int? id;
  String nome;
  String dataNascimento;

  Aluno({this.id, required this.nome, required this.dataNascimento});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'data_nascimento': dataNascimento,
    };
  }


  @override
  String toString() {
    return 'Aluno{id: $id, nome: $nome, dataNascimento: $dataNascimento}';
  }
}

class AlunoDatabase {
  static final AlunoDatabase instance = AlunoDatabase._init();
  static Database? _database;

  AlunoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('aluno.db');
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE TB_ALUNOS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        data_nascimento TEXT NOT NULL
      )
    ''');
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    await _createDB(database, 1);
    return database;
  }

  Future<int> insertAluno(Aluno aluno) async {
    final db = await database;
    return await db.insert('TB_ALUNOS', aluno.toMap());
  }

  Future<Aluno?> getAluno(int id) async {
  final db = await database;
  final maps = await db.query(
    'TB_ALUNOS',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isEmpty) return null;

   return Aluno(
    id: maps.first['id'] as int?,
    nome: maps.first['nome'] as String,
    dataNascimento: maps.first['data_nascimento'] as String,
  );
}

  Future<List<Aluno>> getAllAlunos() async {
    final db = await database;
    final maps = await db.query('TB_ALUNOS');

    return List.generate(maps.length, (i) {
    return Aluno(
      id: maps[i]['id'] as int?,
      nome: maps[i]['nome'] as String,
      dataNascimento: maps[i]['data_nascimento'] as String,
    );
  });
}

  Future<int> updateAluno(Aluno aluno) async {
    final db = await database;
    return await db.update(
      'TB_ALUNOS',
      aluno.toMap(),
      where: 'id = ?',
      whereArgs: [aluno.id],
    );
  }

  Future<int> deleteAluno(int id) async {
    final db = await database;
    return await db.delete(
      'TB_ALUNOS',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

void main() async {
  final db = AlunoDatabase.instance;

  final aluno = Aluno(nome: 'João', dataNascimento: '2000-01-01');
  int alunoId = await db.insertAluno(aluno);

  Aluno? retrievedAluno = await db.getAluno(alunoId);
  if (retrievedAluno == null) {
    print('Aluno não encontrado');
    return;
  }

  print('Aluno recuperado: $retrievedAluno');

  retrievedAluno.nome = 'João da Silva';
  await db.updateAluno(retrievedAluno);

  List<Aluno> alunos = await db.getAllAlunos();
  print('Todos os alunos: $alunos');

  await db.deleteAluno(alunoId);
}