//Estructura de datos que usara la aplicacion para facilitar la comunicacion con la API

class CalidadAireModelo {
  final double promedioPM25;
  final double indiceExposicion;
  final String nivelRiesgo;

  CalidadAireModelo({
    required this.promedioPM25,
    required this.indiceExposicion,
    required this.nivelRiesgo,
  });
}
