import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static const String dbName = 'gastos.db';

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT,
        monto REAL,
        fecha TEXT,
        idCategoria INTEGER,
        idTipo INTEGER,
        observaciones TEXT,
        FOREIGN KEY (idCategoria) REFERENCES categorias(id),
        FOREIGN KEY (idTipo) REFERENCES tipos(id)
      );
    ''');

    // Datos iniciales para tipos y categorías
    await db.insert('tipos', {'nombre': 'INGRESO'});
    await db.insert('tipos', {'nombre': 'EGRESO'});

    await db.insert('categorias', {'nombre': 'ALIMENTACIÓN'});
    await db.insert('categorias', {'nombre': 'VIVIENDA'});
    await db.insert('categorias', {'nombre': 'SALUD'});
  }

  static Future<void> insertarGasto(Map<String, dynamic> gasto) async {
    final db = await getDatabase();
    await db.insert('gastos', gasto);
  }

  static Future<void> actualizarGasto(Map<String, dynamic> gasto) async {
    final db = await getDatabase();
    await db.update('gastos', gasto, where: 'id = ?', whereArgs: [gasto['id']]);
  }

  static Future<Map<String, dynamic>?> obtenerGastoPorId(int id) async {
    final db = await getDatabase();
    final result = await db.query(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}
