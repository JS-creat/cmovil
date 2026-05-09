import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Busqueda extends StatefulWidget {
  const Busqueda({super.key});
  @override
  State<Busqueda> createState() => _BusquedaState();
}

class _BusquedaState extends State<Busqueda> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('Buscar producto:'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.go("/");
              },
              child: const Text("regresar"),
            ),
          ],
        ),
      ),
    );
  }
}
