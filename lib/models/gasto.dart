class Gasto {
  int? id;
  String descripcion;
  double monto;
  String fecha;
  int idCategoria;
  int idTipo;
  String observaciones;

  Gasto({
    this.id,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.idCategoria,
    required this.idTipo,
    required this.observaciones,
  });

  factory Gasto.fromMap(Map<String, dynamic> map) => Gasto(
    id: map['id'],
    descripcion: map['descripcion'],
    monto: map['monto'],
    fecha: map['fecha'],
    idCategoria: map['idCategoria'],
    idTipo: map['idTipo'],
    observaciones: map['observaciones'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'descripcion': descripcion,
    'monto': monto,
    'fecha': fecha,
    'idCategoria': idCategoria,
    'idTipo': idTipo,
    'observaciones': observaciones,
  };
}
