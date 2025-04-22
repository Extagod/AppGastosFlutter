import 'package:flutter/material.dart';
import 'package:evaluacion_interciclo/db/db_helper.dart';
import 'package:intl/intl.dart';

class EditarGastoScreen extends StatefulWidget {
  final int id;
  final String descripcion;
  final double monto;
  final String fecha;
  final int idCategoria;
  final int idTipo;
  final String observaciones;

  const EditarGastoScreen({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.idCategoria,
    required this.idTipo,
    required this.observaciones,
    Key? key,
  }) : super(key: key);

  @override
  _EditarGastoScreenState createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  final _formKey = GlobalKey<FormState>();

  final descripcionCtrl = TextEditingController();
  final montoCtrl = TextEditingController();
  final observacionesCtrl = TextEditingController();

  String fechaSeleccionada = '';
  int? tipoSeleccionado;
  int? categoriaSeleccionada;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> categorias = [];

  @override
  void initState() {
    super.initState();
    descripcionCtrl.text = widget.descripcion;
    montoCtrl.text = widget.monto.toString();
    observacionesCtrl.text = widget.observaciones;
    fechaSeleccionada = widget.fecha;
    tipoSeleccionado = widget.idTipo;
    categoriaSeleccionada = widget.idCategoria;

    _cargarTiposYCategorias();
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

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(fechaSeleccionada),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (seleccionada != null) {
      setState(() {
        fechaSeleccionada = DateFormat('yyyy-MM-dd').format(seleccionada);
      });
    }
  }

  void _guardarEdicion() async {
    if (_formKey.currentState!.validate()) {
      final updatedGasto = {
        'id': widget.id,
        'descripcion': descripcionCtrl.text,
        'monto': double.tryParse(montoCtrl.text) ?? 0,
        'fecha': fechaSeleccionada,
        'idTipo': tipoSeleccionado,
        'idCategoria': categoriaSeleccionada,
        'observaciones': observacionesCtrl.text,
      };

      await DBHelper.actualizarGasto(updatedGasto);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gasto actualizado correctamente')),
      );

      Navigator.pop(context); // Volver a la lista de gastos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Gasto'),
        backgroundColor: const Color.fromARGB(255, 6, 209, 245),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: descripcionCtrl,
                label: 'Descripción',
                icon: Icons.description,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: montoCtrl,
                label: 'Monto',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Ingrese un monto' : null,
              ),
              SizedBox(height: 16),
              _buildDropdownField(
                label: 'Tipo',
                value: tipoSeleccionado,
                items: tipos,
                onChanged: (value) => setState(() => tipoSeleccionado = value),
              ),
              SizedBox(height: 12),
              _buildDropdownField(
                label: 'Categoría',
                value: categoriaSeleccionada,
                items: categorias,
                onChanged:
                    (value) => setState(() => categoriaSeleccionada = value),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: observacionesCtrl,
                label: 'Observaciones',
                icon: Icons.comment,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _seleccionarFecha(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: TextEditingController(text: fechaSeleccionada),
                    label: 'Fecha',
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _guardarEdicion,
                child: Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 4, 197, 245),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Campo de texto genérico con icono
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
      validator: validator,
    );
  }

  // Campo de dropdown genérico
  Widget _buildDropdownField({
    required String label,
    required int? value,
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
}
