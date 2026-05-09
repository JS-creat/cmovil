import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:lucky/models/ubicacion_item.dart';
import 'package:lucky/services/ubicacion_service.dart';

class InformacionCompra extends StatefulWidget {
  const InformacionCompra({super.key});

  @override
  State<InformacionCompra> createState() => _InformacionCompraState();
}

class _InformacionCompraState extends State<InformacionCompra> {
  final TextEditingController _numeroDocumentoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final UbicacionService _ubicacionService = UbicacionService();

  List<UbicacionItem> _tiposDocumento = [];
  List<UbicacionItem> _departamentos = [];
  List<UbicacionItem> _provincias = [];
  List<UbicacionItem> _distritos = [];

  UbicacionItem? _tipoDocumentoSeleccionado;
  UbicacionItem? _departamentoSeleccionado;
  UbicacionItem? _provinciaSeleccionada;
  UbicacionItem? _distritoSeleccionado;

  int _tipoEntrega = 1;
  double? _costoEnvioCalculado;
  String? _nombreAgencia, _direccionAgencia, _tiempoEstimadoEnvio;
  bool _isLoading = true;
  bool _calculandoEnvio = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  bool get _isFormValid {
    if (_tipoDocumentoSeleccionado == null) return false;
    if (_numeroDocumentoController.text.trim().isEmpty) return false;
    if (_telefonoController.text.trim().isEmpty) return false;

    if (_tipoEntrega == 2) {
      if (_departamentoSeleccionado == null) return false;
      if (_provinciaSeleccionada == null) return false;
      if (_distritoSeleccionado == null) return false;
      if (_costoEnvioCalculado == null) return false;
      if (_calculandoEnvio) return false;
    }

    return true;
  }

  Future<void> _cargarDatosIniciales() async {
    await Future.wait([_cargarTiposDocumento(), _cargarDepartamentos()]);
    _cargarDatosUsuario();
    setState(() => _isLoading = false);
  }

  Future<void> _cargarDatosUsuario() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _numeroDocumentoController.text = auth.numeroDocumento ?? '';
    _telefonoController.text = auth.telefono ?? '';

    if (auth.idTipoDocumento != null && _tiposDocumento.isNotEmpty) {
      _tipoDocumentoSeleccionado = _tiposDocumento.firstWhere(
        (t) => t.id == auth.idTipoDocumento,
        orElse: () => UbicacionItem(id: 0, nombre: ''),
      );
      if (_tipoDocumentoSeleccionado?.id == 0)
        _tipoDocumentoSeleccionado = null;
      setState(() {});
    }
  }

  Future<void> _cargarTiposDocumento() async {
    try {
      _tiposDocumento = await _ubicacionService.obtenerTiposDocumento();
    } catch (e) {
      _mostrarError('No se pudieron cargar los tipos de documento');
    }
  }

  Future<void> _cargarDepartamentos() async {
    try {
      _departamentos = await _ubicacionService.obtenerDepartamentos();
    } catch (e) {
      _mostrarError('No se pudieron cargar los departamentos');
    }
  }

  Future<void> _cargarProvincias(int id) async {
    setState(() {
      _provincias = [];
      _distritos = [];
      _provinciaSeleccionada = null;
      _distritoSeleccionado = null;
      _costoEnvioCalculado = null;
      _nombreAgencia = _direccionAgencia = _tiempoEstimadoEnvio = null;
    });
    try {
      _provincias = await _ubicacionService.obtenerProvincias(id);
      setState(() {});
    } catch (e) {
      _mostrarError('No se pudieron cargar las provincias');
    }
  }

  Future<void> _cargarDistritos(int id) async {
    setState(() {
      _distritos = [];
      _distritoSeleccionado = null;
      _costoEnvioCalculado = null;
      _nombreAgencia = _direccionAgencia = _tiempoEstimadoEnvio = null;
    });
    try {
      _distritos = await _ubicacionService.obtenerDistritos(id);
      setState(() {});
    } catch (e) {
      _mostrarError('No se pudieron cargar los distritos');
    }
  }

  Future<void> _calcularEnvio(int id) async {
    setState(() {
      _calculandoEnvio = true;
      _costoEnvioCalculado = null;
    });

    try {
      final r = await _ubicacionService.calcularCostoEnvio(id);
      setState(() {
        _costoEnvioCalculado = r['costo_envio'] as double;
        _nombreAgencia = r['nombre_agencia'];
        _direccionAgencia = r['direccion_agencia'];
        _tiempoEstimadoEnvio = r['tiempo_estimado'];
        _calculandoEnvio = false;
      });
    } catch (e) {
      setState(() => _calculandoEnvio = false);
      _mostrarError(e.toString());
    }
  }

  void _mostrarError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _continuarPago() async {
    if (!_isFormValid) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final ok = await auth.actualizarDatosContacto(
      idTipoDocumento: _tipoDocumentoSeleccionado!.id,
      numeroDocumento: _numeroDocumentoController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );
    if (!ok) {
      _mostrarError('No se pudieron guardar tus datos');
      return;
    }

    context.push(
      '/resumen-compra',
      extra: {
        'nombreUsuario':
            '${auth.usuario?.nombres ?? ''} ${auth.usuario?.apellidos ?? ''}'
                .trim(),
        'idTipoDocumento': _tipoDocumentoSeleccionado!.id,
        'tipoDocumentoNombre': _tipoDocumentoSeleccionado!.nombre,
        'numeroDocumento': _numeroDocumentoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'idTipoEntrega': _tipoEntrega,
        'departamentoNombre': _departamentoSeleccionado?.nombre,
        'provinciaNombre': _provinciaSeleccionada?.nombre,
        'distritoNombre': _distritoSeleccionado?.nombre,
        'idDistrito': _distritoSeleccionado?.id,
        'costoEnvio': _costoEnvioCalculado ?? 0,
        'nombreAgencia': _nombreAgencia,
        'direccionAgencia': _direccionAgencia,
        'tiempoEstimadoEnvio': _tiempoEstimadoEnvio,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.canPop()
                              ? context.pop()
                              : context.go('/'),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Información de compra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: Colors.black12),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Datos personales',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildDropdown(
                              'Tipo de documento',
                              _tiposDocumento,
                              _tipoDocumentoSeleccionado,
                              (v) => setState(
                                () => _tipoDocumentoSeleccionado = v,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              'Número de documento',
                              'Ingresa tu número de documento',
                              _numeroDocumentoController,
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              'Teléfono',
                              'Ingresa tu teléfono',
                              _telefonoController,
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Datos de entrega',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildRadioOption('Retiro en tienda', 1),
                            _buildRadioOption('Envío a provincia', 2),
                            const SizedBox(height: 20),
                            if (_tipoEntrega == 2) ...[
                              _buildDropdown(
                                'Departamento',
                                _departamentos,
                                _departamentoSeleccionado,
                                (v) {
                                  setState(() => _departamentoSeleccionado = v);
                                  if (v != null) _cargarProvincias(v.id);
                                },
                              ),
                              const SizedBox(height: 24),
                              _buildDropdown(
                                'Provincia',
                                _provincias,
                                _provinciaSeleccionada,
                                (v) {
                                  setState(() => _provinciaSeleccionada = v);
                                  if (v != null) _cargarDistritos(v.id);
                                },
                                enabled: _departamentoSeleccionado != null,
                              ),
                              const SizedBox(height: 24),
                              _buildDropdown(
                                'Distrito',
                                _distritos,
                                _distritoSeleccionado,
                                (v) {
                                  setState(() => _distritoSeleccionado = v);
                                  if (v != null && _tipoEntrega == 2)
                                    _calcularEnvio(v.id);
                                },
                                enabled: _provinciaSeleccionada != null,
                              ),
                              if (_calculandoEnvio) ...[
                                const SizedBox(height: 16),
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Calculando costo de envío...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
            // Footer - Solo se muestra cuando la página ha cargado
            if (!_isLoading)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black12, width: 1),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer<CarritoProvider>(
                          builder: (ctx, cp, _) => Text(
                            'S/ ${(cp.total + (_costoEnvioCalculado ?? 0)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid ? _continuarPago : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? Colors.black
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Continuar con el pago',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController ctrl,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  );

  Widget _buildDropdown(
    String label,
    List<UbicacionItem> items,
    UbicacionItem? value,
    ValueChanged<UbicacionItem?> onChanged, {
    bool enabled = true,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<UbicacionItem>(
            value: value,
            isExpanded: true,
            hint: Text(items.isEmpty ? 'Cargando...' : 'Selecciona una opción'),
            icon: const Icon(Icons.arrow_drop_down),
            items: items
                .map((i) => DropdownMenuItem(value: i, child: Text(i.nombre)))
                .toList(),
            onChanged: enabled && items.isNotEmpty ? onChanged : null,
          ),
        ),
      ),
    ],
  );

  Widget _buildRadioOption(String title, int value) => InkWell(
    onTap: () => setState(() {
      _tipoEntrega = value;
      if (value == 1) {
        _departamentoSeleccionado = _provinciaSeleccionada =
            _distritoSeleccionado = null;
        _provincias = _distritos = [];
        _costoEnvioCalculado = _nombreAgencia = _direccionAgencia =
            _tiempoEstimadoEnvio = null;
        _calculandoEnvio = false;
      }
    }),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: _tipoEntrega == value
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _numeroDocumentoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
