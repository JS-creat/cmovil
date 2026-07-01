import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 👈 Se agregó para limpiar el formato de fecha largo

class InfoPedidoBox extends StatelessWidget {
  final String titulo;
  final String fecha;
  final Color colorFondo;
  final Color colorTexto;
  final IconData icono;

  const InfoPedidoBox({
    super.key, 
    required this.titulo,
    required this.fecha,
    required this.colorFondo,
    required this.colorTexto,
    required this.icono,
  });

  // 🟢 Función interna para formatear la fecha automáticamente
  String _formatearFecha(String fechaRaw) {
    if (fechaRaw.isEmpty || fechaRaw == '---') return fechaRaw;
    try {
      // Intenta parsear el formato ISO 8601 (con T y Z)
      DateTime fechaParseada = DateTime.parse(fechaRaw).toLocal();
      // Retorna el formato limpio: dd-MM-yy (Ej: 04-06-26)
      return DateFormat('dd-MM-yy').format(fechaParseada);
    } catch (e) {
      // Si la fecha ya viene formateada o falla, la devuelve tal cual
      return fechaRaw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // 📉 Reducido a 3.0 para pegar más las cajitas verticalmente
      margin: const EdgeInsets.symmetric(vertical: 3.0), 
      // 📉 Padding reducido (horizontal: 12, vertical: 8) para que sea más delgada
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8), // Bordes más sutiles y limpios de 8
      ),
      child: Row(
        children: [
          // 📉 Icono reducido de 24 a 18 para ganar simetría
          Icon(icono, color: colorTexto, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Hace que la columna ocupe solo el espacio necesario
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: colorTexto.withOpacity(0.8), // Un toque más suave para jerarquía visual
                    fontSize: 11, // 📉 Texto de título más pequeño
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1), // 📉 Espaciado interno mínimo
                Text(
                  _formatearFecha(fecha), // 🟢 Aplica el formateo automático aquí
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 13, // 📉 Fuente del dato principal reducida a 13
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}