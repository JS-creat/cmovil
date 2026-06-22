import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/services/pusher_config.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/auth_provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:lucky/utils/api_config.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final PusherConfig _pusherConfig = PusherConfig();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPusher().then((_) {
        setState(() {
          _messages.add({
            'text':
                "¡Hola, soy Alessia, el asistente de B-EDEN. Estoy aquí para ayudarte en tus consultas. ¿En qué puedo ayudarte?",
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        });
      });
    });
  }

  Future<void> _initPusher() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.usuario?.id.toString() ?? 'guest';
    final token = authProvider.token;

    if (token == null) return;

    await _pusherConfig.initPusher(
      channelName: 'private-chat.$userId',
      eventName: 'new-message',
      authToken: token,
      onEventTriggered: (event) {
        if (!mounted) return;

        dynamic data;
        if (event.data is String) {
          try {
            data = jsonDecode(event.data);
          } catch (e) {
            data = {'message': event.data};
          }
        } else {
          data = event.data;
        }

        setState(() {
          _messages.add({
            'text': data['message'] ?? data['mensaje'] ?? '...',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    _controller.clear();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 1. VALIDACIÓN EN EL MÓVIL: Si el usuario no ha iniciado sesión
    if (authProvider.token == null || authProvider.usuario == null) {
      setState(() {
        _messages.add({
          'text': text,
          'isUser': true,
          'timestamp': DateTime.now(),
        });
        _messages.add({
          'text':
              'Para poder conversar con Alessia, por favor inicia sesión en tu cuenta primero.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
      return; // Detiene la ejecución aquí, evita enviar la petición al servidor
    }

    // 2. FLUJO NORMAL: Si está logueado, intentamos enviar el mensaje
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final userId = authProvider.usuario?.id;

      // Le ponemos un límite de 5 segundos de espera al servidor web
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/chat/message'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authProvider.token}',
            },
            body: jsonEncode({'user_id': userId, 'message': text}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // Si el backend te devuelve el mensaje directo en el body de la respuesta
          _messages.add({
            'text':
                data['message'] ??
                data['mensaje'] ??
                'Conexión exitosa, pero sin respuesta.',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
      } else {
        throw Exception('Error del servidor');
      }
    } catch (e) {
      // 3. RESPUESTA DE CAÍDA / ERROR
      setState(() {
        _messages.add({
          'text':
              'Lo siento, en este momento no puedo conectarme con el servidor. Por favor, inténtalo más tarde.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pusherConfig.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Fondo sutil estilo chat
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        titleSpacing: 8,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFED1C24).withAlpha(30),
              child: const Icon(Icons.support_agent, color: Color(0xFFED1C24)),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Alessia (B-EDEN)',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'En línea',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<CarritoProvider>(
            builder: (context, carritoProvider, child) {
              final cantidadTotal = carritoProvider.cantidadTotal;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => context.push('/carrito'),
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  if (cantidadTotal > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFED1C24),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cantidadTotal > 9 ? '9+' : cantidadTotal.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black12, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Lista de Mensajes
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEFF1),
                          borderRadius: BorderRadius.circular(
                            16,
                          ).copyWith(bottomLeft: const Radius.circular(0)),
                        ),
                        child: const _TypingIndicator(),
                      ),
                    );
                  }

                  final msg = _messages[index];
                  final isUser = msg['isUser'];

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color(0xFFECEFF1),
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isUser ? const Radius.circular(0) : null,
                          bottomLeft: !isUser ? const Radius.circular(0) : null,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input de Envío de Mensajes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F6F9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Indicador de Escritura Ajustado
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => __TypingIndicatorState();
}

class __TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (i) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.15, 0.5 + i * 0.15, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade600.withAlpha(
                  (_animations[index].value * 255).round().clamp(0, 255),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
