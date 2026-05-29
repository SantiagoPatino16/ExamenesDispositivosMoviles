import 'dart:ui';
import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import '../servicios/moneda_servicio.dart';
import '../modelos/moneda.dart';
import '../modelos/cambio_moneda.dart';
import 'pantalla_login.dart';

class PantallaPrincipal extends StatefulWidget {
  final String token;

  const PantallaPrincipal({super.key, required this.token});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AutenticacionServicio _authServicio = AutenticacionServicio();
  final MonedaServicio _monedaServicio = MonedaServicio();

  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  List<Moneda> _monedas = [];
  List<CambioMoneda> _resultados = [];
  Moneda? _monedaSeleccionada;
  bool _cargandoMonedas = true;
  bool _consultando = false;

  @override
  void initState() {
    super.initState();
    _cargarMonedas();
  }

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  Future<void> _cargarMonedas() async {
    setState(() => _cargandoMonedas = true);
    try {
      final monedas = await _monedaServicio.listarMonedas(widget.token);
      setState(() {
        _monedas = monedas;
        _cargandoMonedas = false;
        if (_monedas.isNotEmpty) _monedaSeleccionada = _monedas.first;
      });
    } catch (e) {
      setState(() => _cargandoMonedas = false);
      _mostrarError(e.toString());
    }
  }

  Future<void> _consultarCambios() async {
    if (_monedaSeleccionada == null) {
      _mostrarError('Seleccione una moneda');
      return;
    }

    DateTime? fechaInicio;
    DateTime? fechaFin;
    try {
      fechaInicio = DateTime.parse(_fechaInicioController.text.trim());
      fechaFin = DateTime.parse(_fechaFinController.text.trim());
    } catch (_) {
      _mostrarError('Formato de fecha inválido. Use YYYY-MM-DD');
      return;
    }

    if (fechaInicio.isAfter(fechaFin)) {
      _mostrarError('La fecha inicio debe ser anterior a la fecha fin');
      return;
    }

    setState(() => _consultando = true);
    try {
      final cambios = await _monedaServicio.listarCambiosPorPeriodo(
        token: widget.token,
        idMoneda: _monedaSeleccionada!.id,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      setState(() {
        _resultados = cambios;
        _consultando = false;
      });
      if (cambios.isEmpty) {
        _mostrarInfo('No hay datos en el período seleccionado');
      } else {
        _mostrarInfo('Se encontraron ${cambios.length} registros');
      }
    } catch (e) {
      setState(() => _consultando = false);
      _mostrarError(e.toString());
    }
  }

  Future<void> _cerrarSesion() async {
    await _authServicio.cerrarSesion();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaLogin()),
      );
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _mostrarInfo(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0284C7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context, TextEditingController controller) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F172A),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      setState(() {
        final mes = selected.month.toString().padLeft(2, '0');
        final dia = selected.day.toString().padLeft(2, '0');
        controller.text = "${selected.year}-$mes-$dia";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Deep navy Slate 900
            Color(0xFF1E293B), // Slate 800
            Color(0xFF0F172A), // Deep navy Slate 900
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Cambio de Monedas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.0,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                onPressed: _cerrarSesion,
                tooltip: 'Cerrar sesión',
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _cargandoMonedas
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF34D399)),
                        ),
                      )
                    : DropdownButtonFormField<Moneda>(
                        value: _monedaSeleccionada,
                        dropdownColor: const Color(0xFF1E293B),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Seleccionar moneda',
                          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                          floatingLabelStyle: const TextStyle(color: Color(0xFF34D399)),
                          prefixIcon: const Icon(
                            Icons.currency_exchange,
                            color: Color(0xFF34D399),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items: _monedas.map((moneda) {
                          return DropdownMenuItem(
                            value: moneda,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on_outlined,
                                  size: 18,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  moneda.moneda,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (moneda) {
                          setState(() => _monedaSeleccionada = moneda);
                        },
                      ),
              ),
              const SizedBox(height: 16),
              // Start Date Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _fechaInicioController,
                  readOnly: true,
                  onTap: () => _seleccionarFecha(context, _fechaInicioController),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Fecha desde',
                    hintText: 'Seleccione una fecha',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    floatingLabelStyle: const TextStyle(color: Color(0xFF34D399)),
                    prefixIcon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF34D399),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // End Date Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _fechaFinController,
                  readOnly: true,
                  onTap: () => _seleccionarFecha(context, _fechaFinController),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Fecha hasta',
                    hintText: 'Seleccione una fecha',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    floatingLabelStyle: const TextStyle(color: Color(0xFF34D399)),
                    prefixIcon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF34D399),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Query Button with Gradient
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _consultando ? null : _consultarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: _consultando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Consultar Cambios',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Results Header
              const Text(
                'Resultados Históricos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              // Results List/State
              Expanded(
                child: _resultados.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            margin: const EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4).withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.analytics_outlined,
                                    size: 48,
                                    color: Color(0xFF06B6D4),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Sin registros aún',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Elige una moneda y rango de fechas para ver el historial',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _resultados.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final cambio = _resultados[index];
                          final fechaStr =
                              '${cambio.fecha.day.toString().padLeft(2, '0')}/${cambio.fecha.month.toString().padLeft(2, '0')}/${cambio.fecha.year}';
                          final isPositive = cambio.valor > 0; // Keeping original comparison logic
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      width: 5,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      // Trend icon badge
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                          color: isPositive ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Text info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha: $fechaStr',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Historial de cambio',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Rates values
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${cambio.valor.toStringAsFixed(4)}',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: isPositive ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isPositive ? 'ACTIVO' : 'BAJO',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isPositive ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
