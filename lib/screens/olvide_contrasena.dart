import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/utils/dio_client.dart';

class OlvideContrasena extends StatefulWidget {
  const OlvideContrasena({super.key});

  @override
  State<OlvideContrasena> createState() => _OlvideContrasenaState();
}

class _OlvideContrasenaState extends State<OlvideContrasena> {
  final _emailController = TextEditingController();
  bool _enviando = false;
  bool _enviado = false;
  String? _error;

  Future<void> _enviarEnlace() async {
    final correo = _emailController.text.trim();

    if (correo.isEmpty || !correo.contains('@')) {
      setState(() => _error = 'Ingresa un correo electrónico válido');
      return;
    }

    setState(() {
      _enviando = true;
      _error = null;
    });

    try {
      final response = await ApiClient.dio.post(
        '/password/forgot',
        data: {'correo': correo},
      );

      if (response.data['success'] == true) {
        setState(() {
          _enviado = true;
          _enviando = false;
        });
      } else {
        setState(() {
          _error = response.data['message'] ?? 'No se pudo enviar el enlace';
          _enviando = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message'] ??
            'Error de conexión. Intenta nuevamente.';
        _enviando = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/'),
                    child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recuperar contraseña',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.black12),
            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                padding: const EdgeInsets.all(24),
                child: _enviado ? _buildConfirmacion() : _buildFormulario(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'No te preocupes. Ingresa tu correo electrónico y te enviaremos '
          'un enlace seguro para que puedas restablecerla y elegir una nueva.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 24),
        const Text(
          'Correo electrónico',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _error != null ? Colors.red : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'ejemplo@correo.com',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _enviando ? null : _enviarEnlace,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _enviando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Enviar enlace de recuperación',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Volver al inicio de sesión',
              style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmacion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 20),
        const Text(
          'Revisa tu correo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Si el correo ${_emailController.text.trim()} está registrado, '
          'te enviamos un enlace para restablecer tu contraseña. '
          'Ábrelo desde tu correo para continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Volver al inicio de sesión',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}