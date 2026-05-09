// models/carrito_model.dart
import 'package:lucky/models/item_carrito_model.dart';

class CarritoModel {
  final int idCarrito;
  final int idUsuario;
  final List<ItemCarritoModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CarritoModel({
    required this.idCarrito,
    required this.idUsuario,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory CarritoModel.fromJson(Map<String, dynamic> json) {
    return CarritoModel(
      idCarrito: json['id_carrito'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((item) => ItemCarritoModel.fromJson(item))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get cantidadTotal => items.fold(0, (sum, item) => sum + item.cantidad);
  bool get estaVacio => items.isEmpty;
}
