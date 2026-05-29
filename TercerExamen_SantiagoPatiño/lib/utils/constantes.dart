class Constantes {
  //Ciudades con las coordenadas
  static const Map<String, Map<String, double>> ciudades = {
    "Medellin": {"lat": 6.2442, "lon": -75.5812},
    "Bogota": {"lat": 4.7110, "lon": -74.0721},
    "Cali": {"lat": 3.4516, "lon": -76.5320},
    "Barranquilla": {"lat": 10.9685, "lon": -74.7813},
    "Cartagena": {"lat": 10.3931, "lon": -75.4832},
  };

  //Variable con la API
  static const String apiUrl =
      "https://air-quality-api.open-meteo.com/v1/air-quality";
}
