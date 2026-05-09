import 'package:lucky/models/producto_model.dart';
import 'package:lucky/models/variante_model.dart';

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
      'imagenes': producto.imagenes,
      'imagen_principal': producto.imagenPrincipal,
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
