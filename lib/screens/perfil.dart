import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:lucky/providers/auth_provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:lucky/providers/favoritos_provider.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final usuario = authProvider.usuario;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Mi cuenta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.black12),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Información del usuario
                    if (usuario != null) ...[
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Symbols.person,
                                size: 70,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              usuario.nombreCompleto,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              usuario.correo,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],

                    // Opciones del menú
                    _buildMenuItem(
                      icon: Symbols.badge,
                      title: 'Información de cuenta',
                      onTap: () {
                        context.push('/informacion-cuenta');
                      },
                    ),
                    _buildMenuItem(
                      icon: Symbols.shopping_cart,
                      title: 'Mis compras',
                      onTap: () {
                        context.push('/mis-pedidos');
                      },
                    ),
                    _buildMenuItem(
                      icon: Symbols.confirmation_number,
                      title: 'Mis cupones',
                      onTap: () {
                        context.push('/cupones');
                      },
                    ),
                    /*_buildMenuItem(
                      icon: Symbols.notifications,
                      title: 'Notificaciones',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente: Notificaciones'),
                          ),
                        );
                      },
                    ),*/
                    // Botón cerrar sesión
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Symbols.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: const Icon(Symbols.logout, color: Color(0xFFED1C24)),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFED1C24),
          ),
        ),
        onTap: () async {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final carritoProvider = Provider.of<CarritoProvider>(
            context,
            listen: false,
          );
          final favoritosProvider = Provider.of<FavoritosProvider>(
            context,
            listen: false,
          );

          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cerrar sesión'),
              content: const Text(
                '¿Estás seguro de que quieres cerrar sesión?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFED1C24),
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            await authProvider.logout();
            carritoProvider.cerrarSesion();
            favoritosProvider.cerrarSesion();

            if (context.mounted) {
              context.go('/');
            }
          }
        },
      ),
    );
  }
}