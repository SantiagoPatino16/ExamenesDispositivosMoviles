import 'dart:math'; // Para sin(), cos(), atan2(), sqrt()

//Modelo para representarlas coordenadas geograficas
class Location {
  final double latitude; //Latitud
  final double longitude; //Longitud

  //Constructor principal
  Location({required this.latitude, required this.longitude});

  //Factory para que el constructor cree las coordenadas mas legible
  factory Location.fromCoordinates(double lat, double lng) {
    return Location(latitude: lat, longitude: lng);
  }

  //Factory para crear desde un mapa (JSON)
  factory Location.fromJson(Map<String, dynamic> json) {
    //Agarra todo el JSON
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  //Ubicacion de medellin
  factory Location.medellin() {
    return Location(latitude: 6.2442, longitude: -75.5812);
  }

  //Ubicacion vacia
  factory Location.empty() {
    return Location(latitude: 0, longitude: 0);
  }

  //Propiedades calculadas
  /// ¿Es una ubicación válida? (no es 0,0)
  bool get isValid => latitude != 0.0 && longitude != 0.0;

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  // Agrega esto en la clase Location, después de toJson()

  /// Calcula distancia en KILÓMETROS hasta otra ubicación
  double distanceTo(Location other) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    double lat1 = latitude * 3.14159 / 180;
    double lat2 = other.latitude * 3.14159 / 180;
    double deltaLat = (other.latitude - latitude) * 3.14159 / 180;
    double deltaLng = (other.longitude - longitude) * 3.14159 / 180;

    double a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// ¿Está dentro de un radio específico? (en km)
  bool isWithinRadius(Location other, {required double radiusKm}) {
    return distanceTo(other) <= radiusKm;
  }
}
