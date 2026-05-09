class UbicacionItem {
  final int id;
  final String nombre;
  final double costoEnvio;
  final String? nombreAgencia;

  UbicacionItem({
    required this.id,
    required this.nombre,
    this.costoEnvio = 0.0,
    this.nombreAgencia,
  });

  factory UbicacionItem.fromJson(Map<String, dynamic> json) {
    return UbicacionItem(
      id:
          int.tryParse(
            (json['id'] ??
                    json['id_distrito'] ??
                    json['id_provincia'] ??
                    json['id_departamento'] ??
                    json['id_tipo_documento'])
                .toString(),
          ) ??
          0,
      nombre:
          (json['nombre'] ??
                  json['nombre_distrito'] ??
                  json['nombre_provincia'] ??
                  json['nombre_departamento'] ??
                  json['nombre_tipo_documento'] ??
                  '')
              .toString(),
      costoEnvio: double.tryParse((json['costo_envio'] ?? 0).toString()) ?? 0.0,
      nombreAgencia: json['nombre_agencia']?.toString(),
    );
  }
}
