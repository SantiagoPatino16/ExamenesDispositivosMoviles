//Dependencias necesarias
import '../servicios/api_servicio.dart'; //Llama a la API
import '../modelos/calidad_aire_modelo.dart'; //Usa el modelo de datos que se tiene de prefijo
import '../utils/constantes.dart'; //Para usar las ciudades predefinidas

class CalidadAireControlador {
  final ApiServicio _apiServicio = ApiServicio(); //Instnacia del servicio API

  //Metodo para calcular el riesgo
  Future<CalidadAireModelo> calcularRiesgo({
    required String ciudad,
    required String fecha,
    required double horasExposicion,
  })
  //La funcion espera resultados de la API
  async {
    //Obtitne las coordenadas de la ciudad seleccionada
    final coordenadas = Constantes.ciudades[ciudad];
    if (coordenadas == null) {
      throw Exception("Ciudad no valida o no encontrada.");
    }

    //Llama al servicio para obtener los datos de la API
    final data = await _apiServicio.obtenerCalidadAire(
      lat: coordenadas["lat"]!,
      lon: coordenadas["lon"]!,
      fecha: fecha,
    );

    //Calcular el promedio diario de PM2.5
    List<dynamic> pm2_5Values = data["hourly"]["pm2_5"];
    double suma = 0;
    int count = 0;
    for (var value in pm2_5Values) {
      if (value != null) {
        suma += value;
        count++;
      }
    }

    if (count == 0) {
      throw Exception(
        "No se encontraron datos de PM2.5 para la fecha seleccionada.",
      );
    }
    double promedioPM25 = suma / count;

    // Formula propuesta
    double indiceExposicion = promedioPM25 * horasExposicion;

    //Clasificacion
    String nivelRiesgo;
    if (indiceExposicion < 100) {
      nivelRiesgo = "Bajo ";
    } else if (indiceExposicion <= 200) {
      nivelRiesgo = "Moderado";
    } else {
      nivelRiesgo = "Alto";
    }

    //Retorna los resultados
    return CalidadAireModelo(
      promedioPM25: promedioPM25,
      indiceExposicion: indiceExposicion,
      nivelRiesgo: nivelRiesgo,
    );
  }
}
