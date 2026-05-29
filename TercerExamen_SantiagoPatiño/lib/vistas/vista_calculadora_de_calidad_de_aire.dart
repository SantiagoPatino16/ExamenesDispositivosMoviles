import 'package:flutter/material.dart';
import '../controladores/calidad_aire_controlador.dart';
import '../modelos/calidad_aire_modelo.dart';

class VistaCalculadoraDeCalidadDeAire extends StatefulWidget {
  const VistaCalculadoraDeCalidadDeAire({super.key});

  @override
  State<StatefulWidget> createState() => _VistaCalculadoraState(); //Crea un state para cada widget (los separa)
}

class _VistaCalculadoraState extends State<VistaCalculadoraDeCalidadDeAire> {
  final _estadoFormulario = GlobalKey<FormState>();
  final CalidadAireControlador _controlador =
      CalidadAireControlador(); //Controlador para determinar el riesgo

  //Variables de estado:
  String? _ciudadSeleccionada;
  String _fecha = "";
  String _horasExposicion = "";
  String _resultado = "";

  // Variables de UI nuevas:
  CalidadAireModelo? _resultadoModelo;
  String? _errorMsg;
  bool _estaCargando = false;

  final _fechaController = TextEditingController(); //Controla el input de fecha
  final _horasController = TextEditingController(); //Controla el input de horas

  @override
  void dispose() {
    _fechaController.dispose();
    _horasController.dispose();
    super.dispose();
  }

  // Abre el date picker nativo para seleccionar la fecha de forma más intuitiva y sin errores
  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime fechaInicial = DateTime.now();
    if (_fecha.isNotEmpty) {
      final partes = _fecha.split('-');
      if (partes.length == 3) {
        final anio = int.tryParse(partes[0]);
        final mes = int.tryParse(partes[1]);
        final dia = int.tryParse(partes[2]);
        if (anio != null && mes != null && dia != null) {
          fechaInicial = DateTime(anio, mes, dia);
        }
      }
    }

    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0xFF1E293B), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccionada != null) {
      final anio = seleccionada.year;
      final mes = seleccionada.month.toString().padLeft(2, '0');
      final dia = seleccionada.day.toString().padLeft(2, '0');
      final fechaFormateada = "$anio-$mes-$dia";
      
      setState(() {
        _fecha = fechaFormateada;
        _fechaController.text = fechaFormateada;
      });
    }
  }

  //Metodo que se activara cuando se active el boton "calcular interface"
  Future<void> _calcularRiesgo() async {
    // Validaciones básicas
    if (_ciudadSeleccionada == null ||
        _ciudadSeleccionada!.isEmpty ||
        _fecha.isEmpty ||
        _horasExposicion.isEmpty) {
      setState(() {
        _errorMsg = "Por favor, complete todos los campos.";
        _resultadoModelo = null;
        _resultado = "Por favor, complete todos los campos.";
      });
      return;
    }

    setState(() {
      _estaCargando = true;
      _errorMsg = null;
      _resultadoModelo = null;
    });

    try {
      // Llamada asíncrona al controlador
      final resultado = await _controlador.calcularRiesgo(
        ciudad: _ciudadSeleccionada!,
        fecha: _fecha,
        horasExposicion: double.parse(_horasExposicion),
      );

      //Resultado
      setState(() {
        _resultadoModelo = resultado;
        _resultado =
            "Indice de exposicion: ${resultado.indiceExposicion.toStringAsFixed(1)}\n"
            "Nivel de riesgo: ${resultado.nivelRiesgo}";
        _estaCargando = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = "Error: $e";
        _resultado = "Error: $e";
        _estaCargando = false;
      });
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_sync_rounded,
            size: 48,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Índice de Exposición",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00796B),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Consulta el riesgo ambiental de tu ciudad según el promedio diario de PM2.5 y tus horas de exposición.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _estaCargando
              ? [Colors.grey[400]!, Colors.grey[500]!]
              : [const Color(0xFF0D9488), const Color(0xFF0F766E)], // Teal gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: _estaCargando
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _estaCargando
              ? null
              : () {
                  if (_estadoFormulario.currentState!.validate()) {
                    _calcularRiesgo();
                  }
                },
          child: Center(
            child: _estaCargando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Calcular Nivel de Riesgo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultadoWidget() {
    if (_estaCargando) {
      return const SizedBox.shrink(); // Ocultar mientras carga
    }

    if (_errorMsg != null) {
      return Card(
        color: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFCA5A5), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_resultadoModelo == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.teal.withOpacity(0.15), width: 1.5),
        ),
        color: Colors.teal.withOpacity(0.02),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                color: Colors.orange.withOpacity(0.4),
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                "Sin Resultados Aún",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Completa los datos de arriba para calcular el índice y ver la clasificación de riesgo.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final model = _resultadoModelo!;
    final nivel = model.nivelRiesgo.trim(); // "Bajo", "Moderado", "Alto"
    
    Color riskColor;
    Color riskBgColor;
    IconData riskIcon;
    String recomendacion;

    if (nivel == "Bajo") {
      riskColor = const Color(0xFF0F766E); // Deep Teal
      riskBgColor = const Color(0xFFF0FDF4); // Soft green
      riskIcon = Icons.health_and_safety_rounded;
      recomendacion = "Calidad del aire segura. Es un buen momento para realizar actividades al aire libre.";
    } else if (nivel == "Moderado") {
      riskColor = const Color(0xFFD97706); // Amber
      riskBgColor = const Color(0xFFFFFBEB); // Soft amber
      riskIcon = Icons.warning_amber_rounded;
      recomendacion = "Calidad del aire aceptable. Personas con problemas respiratorios deben tener precaución.";
    } else {
      riskColor = const Color(0xFFDC2626); // Red
      riskBgColor = const Color(0xFFFEF2F2); // Soft red
      riskIcon = Icons.dangerous_rounded;
      recomendacion = "Alto nivel de exposición. Se aconseja reducir el esfuerzo prolongado o pesado al aire libre.";
    }

    return Card(
      elevation: 6,
      shadowColor: riskColor.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: riskBgColor,
              child: Row(
                children: [
                  Icon(riskIcon, color: riskColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    "Riesgo $nivel",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.extrabold,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "ÍNDICE EXPOSICIÓN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              model.indiceExposicion.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.black,
                                color: riskColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1.5,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "PROMEDIO PM2.5",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${model.promedioPM25.toStringAsFixed(1)} µg/m³",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 36, thickness: 1),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.slate[500], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recomendacion,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.slate[600],
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Calidad del Aire",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2F1), // Verde menta suave
              Color(0xFFF1F5F9), // Slate claro
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _estadoFormulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.teal.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.edit_note_rounded, color: Colors.teal[700]),
                              const SizedBox(width: 8),
                              const Text(
                                "Datos de Exposición",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, thickness: 1),
                          DropdownButtonFormField<String>(
                            value: _ciudadSeleccionada,
                            hint: const Text("Seleccione una ciudad"),
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
                            items: const [
                              DropdownMenuItem(value: "Medellin", child: Text("Medellin")),
                              DropdownMenuItem(value: "Bogota", child: Text("Bogota")),
                              DropdownMenuItem(value: "Cali", child: Text("Cali")),
                              DropdownMenuItem(value: "Barranquilla", child: Text("Barranquilla")),
                              DropdownMenuItem(value: "Cartagena", child: Text("Cartagena")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _ciudadSeleccionada = value;
                              });
                            },
                            validator: (value) =>
                                value == null || value.isEmpty ? "La ciudad es obligatoria" : null,
                            decoration: InputDecoration(
                              labelText: "Ciudad",
                              prefixIcon: const Icon(Icons.location_city_rounded, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.teal.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _fechaController,
                            keyboardType: TextInputType.datetime,
                            onTap: () => _seleccionarFecha(context),
                            decoration: InputDecoration(
                              labelText: "Fecha (YYYY-MM-DD)",
                              prefixIcon: const Icon(Icons.calendar_month_rounded, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.teal.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _fecha = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "La fecha es obligatoria";
                              }
                              final partes = value.split('-');
                              if (partes.length < 3) {
                                return "Formato inválido (YYYY-MM-DD)";
                              }
                              final mes = int.tryParse(partes[1]);
                              final dia = int.tryParse(partes[2]);
                              if (mes == null || mes < 1 || mes > 12) {
                                return "Mes inválido";
                              }
                              if (dia == null || dia < 1 || dia > 31) {
                                return "Día inválido";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _horasController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Horas de exposición diaria",
                              prefixIcon: const Icon(Icons.timer_rounded, color: Colors.teal),
                              suffixText: "horas",
                              suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.teal.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _horasExposicion = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Las horas de exposición son obligatorias";
                              }
                              final double? horas = double.tryParse(value);
                              if (horas == null) {
                                return "Debe ingresar un número válido";
                              }
                              if (horas <= 0) {
                                return "Las horas deben ser mayores a 0";
                              }
                              if (horas > 24) {
                                return "Las horas no pueden superar 24";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          _buildCalculateButton(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildResultadoWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

