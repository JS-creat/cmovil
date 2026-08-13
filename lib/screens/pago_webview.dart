import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lucky/utils/dio_client.dart';

/// Muestra la pantalla de pago de Mercado Pago (la misma que se ve en la
/// web) dentro de un WebView embebido en la app. Detecta a qué URL
/// termina navegando el usuario (éxito/fallo/pendiente) usando las rutas
/// PÚBLICAS de retorno que arma el backend (`/api/pago/movil/...`) y
/// reacciona en consecuencia — no necesita leer el contenido de la
/// página, solo la URL a la que llegó.
class PagoWebview extends StatefulWidget {
  final String initPoint;
  final int idPedido;
  final String numeroPedido;

  const PagoWebview({
    super.key,
    required this.initPoint,
    required this.idPedido,
    required this.numeroPedido,
  });

  @override
  State<PagoWebview> createState() => _PagoWebviewState();
}

class _PagoWebviewState extends State<PagoWebview> {
  late final WebViewController _controller;
  bool _cargando = true;
  // Evita procesar el resultado más de una vez si la URL de retorno
  // dispara varias navegaciones seguidas (por ejemplo, redirecciones
  // intermedias de Mercado Pago).
  bool _resultadoYaProcesado = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _cargando = true);
            _revisarUrlDeRetorno(url);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _cargando = false);
            _revisarUrlDeRetorno(url);
          },
          onNavigationRequest: (request) {
            _revisarUrlDeRetorno(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initPoint));
  }

  // 🟢 Corazón del flujo: identifica si la URL actual es alguna de las
  // rutas públicas de retorno que armamos en el backend
  // (PagoMovilApiController) y navega a la pantalla correspondiente de
  // la app. El backend ya verificó el pago contra Mercado Pago antes de
  // servir esa página — acá solo reaccionamos a cuál fue el resultado.
  void _revisarUrlDeRetorno(String url) {
    if (_resultadoYaProcesado) return;

    if (url.contains('/api/pago/movil/exito')) {
      _resultadoYaProcesado = true;
      _irACompraExitosa();
    } else if (url.contains('/api/pago/movil/fallo')) {
      _resultadoYaProcesado = true;
      _irAFallo();
    } else if (url.contains('/api/pago/movil/pendiente')) {
      _resultadoYaProcesado = true;
      _irAPendiente();
    }
  }

  void _irACompraExitosa() async {
    if (!mounted) return;

    // 🟢 El pago se confirma de forma asíncrona (el backend recién marca
    // el pedido como "Confirmado" cuando este WebView llega a la URL de
    // éxito). Por eso traemos los datos reales y actualizados del
    // pedido en vez de asumir valores fijos, usando el mismo endpoint
    // que ya usa "Mis pedidos" (GET /pedidos/{id}).
    Map<String, dynamic>? pedidoData;
    try {
      final response = await ApiClient.dio.get('/pedidos/${widget.idPedido}');
      if (response.data['success'] == true) {
        pedidoData = response.data['data'];
      }
    } catch (_) {
      // Si falla la consulta, igual navegamos con lo mínimo que ya
      // teníamos (número de pedido); no bloqueamos al usuario por esto.
    }

    if (!mounted) return;

    context.go(
      '/compraExitosa',
      extra: {
        'numeroPedido':
            pedidoData?['numero_pedido'] ?? widget.numeroPedido,
        'totalPedido': pedidoData?['total_pedido'],
        'estadoPedido': pedidoData?['estado_pedido'] ?? 'Confirmado',
        'idPedido': widget.idPedido,
      },
    );
  }

  void _irAFallo() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El pago no se pudo completar'),
        backgroundColor: Colors.red,
      ),
    );
    // Vuelve al resumen de compra para que el usuario pueda reintentar
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _irAPendiente() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tu pago está pendiente de confirmación. Te avisaremos cuando se apruebe.',
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
    context.go('/');
  }

  Future<bool> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar el pago?'),
        content: const Text(
          'Si sales ahora, tu pedido quedará pendiente y podrás retomarlo más tarde desde tus compras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Seguir pagando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFED1C24),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    return salir ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final salir = await _confirmarSalida();
        if (salir && mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: Colors.black,
          title: const Text(
            'Pagar pedido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final salir = await _confirmarSalida();
              if (salir && context.mounted) {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_cargando)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}