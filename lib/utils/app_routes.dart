import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// ─── IMPORTS DE LAS PANTALLAS ───
import '../screens/main_layout.dart';
import '../screens/pagina_principal.dart';
import '../screens/catalogo_parte1.dart';
import '../screens/catalogo_parte2.dart';
import '../screens/catalogo_parte3.dart';
import '../screens/cupones.dart';
import '../screens/favoritos.dart';
import '../screens/perfil.dart';
import '../screens/iniciar_sesion.dart';
import '../screens/registro_usuario.dart';
import '../screens/olvide_contrasena.dart';
import '../screens/carrito.dart';
import '../screens/busqueda.dart';
import '../screens/detalles_producto.dart';
import '../screens/informacion_compra.dart';
import '../screens/resumen_compra.dart';
import '../screens/compra_exitosa.dart';
import '../screens/pedidos.dart';
import '../screens/chat.dart';
import '../screens/informacion_cuenta.dart';
import '../screens/detalles_pedido_screen.dart';
import '../screens/pago_webview.dart';
import '../providers/auth_provider.dart';

final GoRouter appRouter = GoRouter(
  // Cambiado a appRouter para que sea público
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const PaginaPrincipal(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/catalogo',
              name: 'catalogo',
              builder: (context, state) => const CatalogoParte1(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cupones',
              name: 'cupones',
              builder: (context, state) => const Cupones(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favoritos',
              name: 'favoritos',
              builder: (context, state) => const Favoritos(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cuenta',
              name: 'cuenta',
              redirect: (context, state) {
                if (state.fullPath == '/cuenta/registroUsuario' ||
                    state.fullPath == '/cuenta/olvideContrasena') {
                  return null;
                }

                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );

                if (!authProvider.isLoggedIn) {
                  return '/cuenta/iniciarSesion';
                }
                return '/cuenta/perfil';
              },
              routes: [
                GoRoute(
                  path: 'perfil',
                  name: 'perfil',
                  builder: (context, state) => const Perfil(),
                ),
                GoRoute(
                  path: 'iniciarSesion',
                  name: 'login',
                  builder: (context, state) => const IniciarSesion(),
                ),
                GoRoute(
                  path: 'registroUsuario',
                  name: 'registro',
                  builder: (context, state) => const RegistroUsuario(),
                ),
                // 🟢 NUEVO: pantalla de "olvidé mi contraseña". Se agregó
                // también a la excepción del redirect() de arriba, igual
                // que 'registroUsuario', porque un usuario SIN sesión
                // debe poder entrar acá (si no, el redirect lo mandaría
                // de vuelta a iniciarSesion antes de poder usarla).
                GoRoute(
                  path: 'olvideContrasena',
                  name: 'olvideContrasena',
                  builder: (context, state) => const OlvideContrasena(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/carrito',
      name: 'carrito',
      builder: (context, state) => const Carrito(),
    ),
    GoRoute(
      path: '/busqueda',
      name: 'busqueda',
      builder: (context, state) => const Busqueda(),
    ),
    GoRoute(
      path: '/detallesProducto',
      name: 'detalle',
      builder: (context, state) {
        final producto = state.extra as Map<String, dynamic>;
        return DetallesProducto(producto: producto);
      },
    ),
    GoRoute(
      path: '/informacionCompra',
      name: 'informacionCompra',
      builder: (context, state) => const InformacionCompra(),
    ),
    GoRoute(
      path: '/resumen-compra',
      name: 'resumenCompra',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ResumenCompra(data: extra);
      },
    ),
    GoRoute(
      path: '/pagoWebview',
      name: 'pagoWebview',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PagoWebview(
          initPoint: extra['initPoint'],
          idPedido: extra['idPedido'],
          numeroPedido: extra['numeroPedido'],
        );
      },
    ),
    GoRoute(
      path: '/compraExitosa',
      name: 'compraExitosa',
      builder: (context, state) {
        return CompraExitosa(extra: state.extra as Map<String, dynamic>?);
      },
    ),
    GoRoute(
      path: '/mis-pedidos',
      name: 'misPedidos',
      builder: (context, state) => const MisPedidos(),
    ),
    GoRoute(
      path: '/catalogo-parte2',
      name: 'catalogoParte2',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CatalogoParte2(
          genero: extra['genero'],
          generoId: extra['generoId'],
        );
      },
    ),
    GoRoute(
      path: '/catalogo-parte3',
      name: 'catalogoParte3',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CatalogoParte3(
          categoria: extra['categoria'],
          categoriaId: extra['categoriaId'],
          genero: extra['genero'],
          generoId: extra['generoId'],
        );
      },
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const Chat(),
    ),
    GoRoute(
      path: '/informacion-cuenta',
      name: 'informacionCuenta',
      builder: (context, state) => const InformacionCuenta(),
    ),
    GoRoute(
      path: '/detalle-pedido',
      name: 'detallePedido',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final pedido = extra['pedido'];
        return DetallesPedidoScreen(pedido: pedido);
      },
    ),
  ],
);