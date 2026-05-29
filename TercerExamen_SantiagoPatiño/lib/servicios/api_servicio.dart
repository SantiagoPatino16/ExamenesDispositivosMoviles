import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constantes.dart';

class ApiServicio {
  //Construye la URL, hace la peticion HTTP y devuelve/maneja errores
  Future<Map<String, dynamic>> obtenerCalidadAire({
    required double lat,
    required double lon,
    required String fecha,
  }) async {
    // Se construye la URL con los parámetros necesarios
    final String url =
        "${Constantes.apiUrl}"
        "?latitude=$lat"
        "&longitude=$lon"
        "&hourly=pm2_5"
        "&start_date=$fecha"
        "&end_date=$fecha";

    // Se realiza la petición de forma asíncrona
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al consultar la API: ${response.statusCode}");
    }
  }
}
