import 'package:lucky/models/producto_model.dart';
import 'package:lucky/models/variante_model.dart';
import 'package:lucky/utils/api_config.dart';

class ItemCarritoModel {
  final int idDetalle;
  final int cantidad;
  final VarianteModel variante;

  ItemCarritoModel({
    required this.idDetalle,
    required this.cantidad,
    required this.variante,
  });

  factory ItemCarritoModel.fromJson(Map<String, dynamic> json) {
    return ItemCarritoModel(
      idDetalle: json['id_detalle'] ?? 0,
      cantidad: json['cantidad'] ?? 1,
      variante: VarianteModel.fromJson(json['variante'] ?? {}),
    );
  }

  ProductoModel get producto => variante.producto;

  Map<String, dynamic> toMap() {
    return {
      'id_detalle': idDetalle,
      'id_variante': variante.id,
      'id_producto': producto.id,
      'titulo': producto.titulo,
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'precioAntes': producto.precioAntes,
      'descuento': producto.descuento,
      // 🟢 FIX: imagenPrincipal/imagenes llegan del backend como solo el
      // nombre del archivo (ej: "6a0e637701fea.jpg"), no como URL completa.
      // Usamos ApiConfig.imagenProducto() para armar la URL pública real,
      // igual que ya hacemos en detalles_producto.dart.
      'imagenes': producto.imagenes
          .map((filename) => ApiConfig.imagenProducto(filename))
          .toList(),
      'imagen_principal': ApiConfig.imagenProducto(producto.imagenPrincipal),
      'categoria': producto.categoria,
      'categoria_id': producto.categoriaId,
      'genero': producto.genero,
      'talla': variante.talla,
      'color': variante.color,
      'stock': variante.stock,
      'sku': variante.sku,
      'cantidad': cantidad,
    };
  }

  double get subtotal => (producto.precio * cantidad);
  String get titulo => producto.titulo;
  String get talla => variante.talla;
  String? get color => variante.color;
}