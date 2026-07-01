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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB0B3C1),
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () => context.push('/chat'),
        child: const Icon(
          Icons.chat_bubble_rounded,
          color: Colors.black,
          size: 26,
        ),
      ),

      bottomNavigationBar: BarraNavegacion(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          if (index == 4) {
            widget.navigationShell.goBranch(4, initialLocation: true);
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
