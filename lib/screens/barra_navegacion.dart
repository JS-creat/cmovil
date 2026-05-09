import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';  // <-- Importación correcta

class BarraNavegacion extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BarraNavegacion({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      elevation: 8,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Symbols.home),  // <-- Ícono de inicio
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.grid_view),  // <-- Ícono para catálogo
          label: 'Catálogo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.confirmation_number),  // <-- Ícono para cupones
          label: 'Cupones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.favorite),  // <-- Ícono para favoritos
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.person),  // <-- Ícono para cuenta (versión outline)
          label: 'Mi cuenta',
        ),
      ],
    );
  }
}