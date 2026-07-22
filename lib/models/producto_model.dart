import 'variante_model.dart';

class ProductoModel {
  final int id;
  final String titulo;
  final String descripcion;
  final double precio;
  final double? precioAntes;
  final int? descuento;
  final List<String> imagenes;
  final String imagenPrincipal;
  final String? categoria;
  final int? categoriaId;
  final String? genero;
  final List<String> tallas;
  final List<String> colores;
  final String? marca;
  final int stock;
  final String? sku;
  final bool disponible;
  final bool enOferta;
  final List<VarianteModel> variantes;

  ProductoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    this.precioAntes,
    this.descuento,
    required this.imagenes,
    required this.imagenPrincipal,
    this.categoria,
    this.categoriaId,
    this.genero,
    required this.tallas,
    required this.colores,
    this.marca,
    required this.stock,
    this.sku,
    required this.disponible,
    required this.enOferta,
    required this.variantes,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    List<VarianteModel> variantes = [];
    if (json['variantes'] != null) {
      variantes = (json['variantes'] as List)
          .map((v) => VarianteModel.fromJson(v))
          .toList();
    }

    return ProductoModel(
      id: json['id_producto'] ?? json['id'] ?? 0,
      titulo: json['nombre_producto'] ?? json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: toDouble(json['precio'] ?? 0),
      precioAntes: toDouble(
        json['precio_oferta'] ??
            json['precio_antes'] ??
            json['precioAntes'] ??
            json['precio_original'],
      ),
      descuento: json['descuento'],
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : (json['imagen'] != null ? [json['imagen']] : []),
      imagenPrincipal: json['imagen_principal'] ?? json['imagen'] ?? '',
      categoria: json['categoria_nombre'] ?? json['categoria'],
      categoriaId: json['id_categoria'] ?? json['categoria_id'],
      genero: json['genero_nombre'] ?? json['genero'],
      tallas: List<String>.from(json['tallas'] ?? []),
      colores: List<String>.from(json['colores'] ?? []),
      marca: json['marca'],
      stock: json['stock'] ?? 0,
      sku: json['sku'],
      disponible: json['disponible'] ?? true,
      enOferta: json['en_oferta'] ?? false,
      variantes: variantes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'precio_antes': precioAntes,
      'descuento': descuento,
      'imagenes': imagenes,
      'imagen_principal': imagenPrincipal,
      'categoria': categoria,
      'categoria_id': categoriaId,
      'genero': genero,
      'tallas': tallas,
      'colores': colores,
      'marca': marca,
      'stock': stock,
      'sku': sku,
      'disponible': disponible,
      'en_oferta': enOferta,
      'variantes': variantes.map((v) => v.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'precioAntes': precioAntes,
      'descuento': descuento,
      'imagenes': imagenes,
      'imagen_principal': imagenPrincipal,
      'categoria': categoria,
      'categoria_id': categoriaId,
      'genero': genero,
      'tallas': tallas,
      'colores': colores,
      'marca': marca,
      'stock': stock,
      'sku': sku,
      'disponible': disponible,
      'en_oferta': enOferta,
      'variantes': variantes.map((v) => v.toJson()).toList(),
    };
  }

  VarianteModel? getVariante({required String talla, String? color}) {
    try {
      return variantes.firstWhere(
        (v) => v.talla == talla && (color == null || v.color == color),
      );
    } catch (e) {
      return null;
    }
  }

  bool tieneStockTalla(String talla) {
    return variantes.any((v) => v.talla == talla && v.stock > 0);
  }

  List<String> getColoresPorTalla(String talla) {
    return variantes
        .where((v) => v.talla == talla && v.stock > 0 && v.color != null)
        .map((v) => v.color!)
        .toList();
  }
}