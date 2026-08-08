class CuponModel {
  final int id;
  final String codigo;
  final String descripcion;
  final String tipoDescuento; // 'porcentaje' | 'monto_fijo'
  final double valorDescuento;
  final String descuentoFormateado; // ej: "20%" o "S/ 20.00"
  final double montoCompraMinima;
  final String fechaVencimiento; // formato "Y-m-d"
  final int diasRestantes;
  final bool esPrivado;

  CuponModel({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.tipoDescuento,
    required this.valorDescuento,
    required this.descuentoFormateado,
    required this.montoCompraMinima,
    required this.fechaVencimiento,
    required this.diasRestantes,
    required this.esPrivado,
  });

  factory CuponModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CuponModel(
      id: json['id'] ?? 0,
      codigo: json['codigo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipoDescuento: json['tipo_descuento'] ?? '',
      valorDescuento: toDouble(json['valor_descuento']),
      descuentoFormateado: json['descuento_formateado'] ?? '',
      montoCompraMinima: toDouble(json['monto_compra_minima']),
      fechaVencimiento: json['fecha_vencimiento'] ?? '',
      diasRestantes: json['dias_restantes'] ?? 0,
      esPrivado: json['es_privado'] ?? false,
    );
  }
}