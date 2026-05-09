// main_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/screens/barra_navegacion.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BarraNavegacion(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          // 🔥 Lógica especial para el índice de Mi cuenta (índice 4)
          if (index == 4) {
            widget.navigationShell.goBranch(
              4,
              initialLocation: true, // Siempre ir a la rama 4
            );
          } else {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          }
        },
      ),
      body: SafeArea(child: widget.navigationShell),
    );
  }
}
