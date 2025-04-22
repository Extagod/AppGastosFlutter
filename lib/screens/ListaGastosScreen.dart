import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:evaluacion_interciclo/db/db_helper.dart';

class ListaGastosScreen extends StatefulWidget {
  @override
  _ListaGastosScreenState createState() => _ListaGastosScreenState();
}

class _ListaGastosScreenState extends State<ListaGastosScreen> {
  List<Map<String, dynamic>> gastos = [];
  DateTime? fechaInicio;
  DateTime? fechaFin;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (seleccionada != null) {
      setState(() {
        if (esInicio) {
          fechaInicio = seleccionada;
        } else {
          fechaFin = seleccionada;
        }
      });

      _cargarGastos();
    }
  }

  Future<void> _cargarGastos() async {
    final db = await DBHelper.getDatabase();

    String baseQuery = '''
      SELECT g.*, 
             t.nombre AS tipo_nombre, 
             c.nombre AS categoria_nombre
      FROM gastos g
      LEFT JOIN tipos t ON g.idTipo = t.id
      LEFT JOIN categorias c ON g.idCategoria = c.id
    ''';

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (fechaInicio != null && fechaFin != null) {
      whereClause = "WHERE g.fecha BETWEEN ? AND ?";
      whereArgs = [
        DateFormat('yyyy-MM-dd').format(fechaInicio!),
        DateFormat('yyyy-MM-dd').format(fechaFin!),
      ];
    }

    final fullQuery = '$baseQuery $whereClause ORDER BY g.fecha DESC';
    final result = await db.rawQuery(fullQuery, whereArgs);

    setState(() {
      gastos = result;
    });
  }

  Future<void> _confirmarEliminacion(BuildContext context, int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de que deseas eliminar este gasto?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      await _eliminarGasto(id);
    }
  }

  Future<void> _eliminarGasto(int id) async {
    final db = await DBHelper.getDatabase();
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
    _cargarGastos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Gastos'),
        backgroundColor: const Color.fromARGB(255, 47, 128, 237),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _seleccionarFecha(context, true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      fechaInicio == null
                          ? 'Desde'
                          : 'Desde: ${DateFormat('yyyy-MM-dd').format(fechaInicio!)}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => _seleccionarFecha(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      fechaFin == null
                          ? 'Hasta'
                          : 'Hasta: ${DateFormat('yyyy-MM-dd').format(fechaFin!)}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                gastos.isEmpty
                    ? Center(child: Text('No hay gastos registrados.'))
                    : ListView.builder(
                      itemCount: gastos.length,
                      itemBuilder: (context, index) {
                        final gasto = gastos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              gasto['descripcion'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fecha: ${gasto['fecha']}'),
                                Text('Monto: \$${gasto['monto']}'),
                                Text(
                                  'Tipo: ${gasto['tipo_nombre'] ?? 'Desconocido'}',
                                ),
                                Text(
                                  'Categoría: ${gasto['categoria_nombre'] ?? 'Desconocido'}',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/editarGasto',
                                      arguments: {
                                        'id': gasto['id'],
                                        'descripcion': gasto['descripcion'],
                                        'monto': gasto['monto'],
                                        'fecha': gasto['fecha'],
                                        'idCategoria': gasto['idCategoria'],
                                        'idTipo': gasto['idTipo'],
                                        'observaciones': gasto['observaciones'],
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed:
                                      () => _confirmarEliminacion(
                                        context,
                                        gasto['id'],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
