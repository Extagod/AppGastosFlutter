import 'package:flutter/material.dart';
import 'package:evaluacion_interciclo/db/db_helper.dart';
import 'package:evaluacion_interciclo/screens/ListaGastosScreen.dart';
import 'package:intl/intl.dart';

class GastoScreen extends StatefulWidget {
  @override
  _GastoScreenState createState() => _GastoScreenState();
}

class _GastoScreenState extends State<GastoScreen> {
  final _formKey = GlobalKey<FormState>();

  final descripcionCtrl = TextEditingController();
  final montoCtrl = TextEditingController();
  final observacionesCtrl = TextEditingController();

  DateTime fechaSeleccionada = DateTime.now();
  int? tipoSeleccionado;
  int? categoriaSeleccionada;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> categorias = [];

  double totalIngresos = 0.0;
  double totalEgresos = 0.0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarTiposYCategorias();
    _cargarTotales();
  }

  void _cargarTiposYCategorias() async {
    final db = await DBHelper.getDatabase();
    final tiposData = await db.query('tipos');
    final categoriasData = await db.query('categorias');
    setState(() {
      tipos = tiposData;
      categorias = categoriasData;
    });
  }

  void _cargarTotales() async {
    setState(() {
      isLoading = true;
    });
    final db = await DBHelper.getDatabase();
    final ingresosResult = await db.rawQuery(
      "SELECT SUM(monto) as total FROM gastos WHERE idTipo = 1",
    );
    final egresosResult = await db.rawQuery(
      "SELECT SUM(monto) as total FROM gastos WHERE idTipo = 2",
    );

    setState(() {
      totalIngresos =
          (ingresosResult.first['total'] as num?)?.toDouble() ?? 0.0;
      totalEgresos = (egresosResult.first['total'] as num?)?.toDouble() ?? 0.0;
      isLoading = false;
    });
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale("es", "ES"),
    );
    if (picked != null && picked != fechaSeleccionada) {
      if (picked.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('La fecha no puede ser futura')));
        return;
      }
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fechaFormateada =
        "${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Gasto'),
        backgroundColor: const Color.fromARGB(255, 6, 209, 245),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            ;
          },
        ),
      ),

      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingresos y Egresos
                      _buildTotalesCard(),
                      SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: descripcionCtrl,
                              label: 'Descripción',
                              icon: Icons.description,
                            ),
                            SizedBox(height: 12),
                            _buildTextField(
                              controller: montoCtrl,
                              label: 'Monto',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Fecha: $fechaFormateada',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _seleccionarFecha(context),
                                  child: Text('Seleccionar Fecha'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      4,
                                      197,
                                      245,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildDropdownField(
                              value: tipoSeleccionado,
                              label: 'Tipo',
                              items: tipos,
                              onChanged:
                                  (value) => setState(() {
                                    tipoSeleccionado = value;
                                  }),
                            ),
                            SizedBox(height: 12),
                            _buildDropdownField(
                              value: categoriaSeleccionada,
                              label: 'Categoría',
                              items: categorias,
                              onChanged:
                                  (value) => setState(() {
                                    categoriaSeleccionada = value;
                                  }),
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              controller: observacionesCtrl,
                              label: 'Observaciones',
                              icon: Icons.comment,
                            ),
                            SizedBox(height: 24),
                            // Aquí empieza el Row para los botones alineados
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _guardarGasto,
                                  icon: Icon(
                                    Icons.save,
                                    size: 25, // Tamaño del ícono ajustado
                                  ),
                                  label: Text('Guardar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      4,
                                      197,
                                      245,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 6),
                                    textStyle: TextStyle(fontSize: 16),
                                    minimumSize: Size(200, 48),
                                  ),
                                ),

                                ElevatedButton.icon(
                                  icon: Icon(Icons.list),
                                  label: Text('Ver lista de gastos'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ListaGastosScreen(),
                                      ),
                                    ).then((_) => _cargarTotales());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      4,
                                      197,
                                      245,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    minimumSize: Size(200, 48),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // Tarjeta de Ingresos y Egresos

  Widget _buildTotalesCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTotalBox('Ingresos', totalIngresos, Colors.green),
            _buildTotalBox('Egresos', totalEgresos, Colors.red),
          ],
        ),
      ),
    );
  }

  // Caja individual para cada total (Ingresos/Egresos)
  Widget _buildTotalBox(String label, double total, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Campo de texto genérico
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (label == 'Monto' &&
            (double.tryParse(value) == null || double.parse(value) <= 0)) {
          return 'Por favor ingrese un monto válido';
        }
        return null;
      },
    );
  }

  // Campo de dropdown genérico
  Widget _buildDropdownField({
    required int? value,
    required String label,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<int>(
              value: item['id'] as int,
              child: Text(item['nombre']),
            );
          }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione una opción' : null,
    );
  }

  void _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      try {
        final formattedDate = DateFormat(
          'yyyy-MM-dd',
        ).format(fechaSeleccionada);

        final nuevoGasto = {
          'descripcion': descripcionCtrl.text,
          'monto': double.tryParse(montoCtrl.text) ?? 0.0,
          'fecha': formattedDate,
          'idTipo': tipoSeleccionado,
          'idCategoria': categoriaSeleccionada,
          'observaciones': observacionesCtrl.text,
        };

        await DBHelper.insertarGasto(nuevoGasto);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gasto guardado correctamente')));

        // Limpiar los campos manualmente
        descripcionCtrl.clear();
        montoCtrl.clear();
        observacionesCtrl.clear();
        _formKey.currentState!.reset();

        // Resetear otros campos
        setState(() {
          tipoSeleccionado = null;
          categoriaSeleccionada = null;
          fechaSeleccionada = DateTime.now();
        });

        // Recargar los totales
        _cargarTotales();

        // O si prefieres recargar la pantalla actual
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GastoScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el gasto: $e')),
        );
      }
    }
  }
}
