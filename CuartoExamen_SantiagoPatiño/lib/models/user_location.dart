

import 'location.dart';

/// Modelo que representa la ubicación actual del usuario
class UserLocation {
  // PROPIEDADES (Datos que guarda)

  final Location location; // Coordenadas del usuario
  final DateTime timestamp; // Momento en que se obtuvo

  // CONSTRUCTORES

  /// Constructor principal
  UserLocation({required this.location, required this.timestamp});

  /// Crear desde coordenadas simples
  factory UserLocation.fromCoordinates(double lat, double lng) {
    return UserLocation(
      location: Location(latitude: lat, longitude: lng),
      timestamp: DateTime.now(),
    );
  }

  /// Crear desde un objeto Location
  factory UserLocation.fromLocation(Location location) {
    return UserLocation(location: location, timestamp: DateTime.now());
  }

  /// Crear desde un mapa (JSON) - para recuperar datos guardados
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      location: Location.fromJson(json['location']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // PROPIEDADES CALCULADAS

  /// ¿Es una ubicación válida? (no son 0,0)
  bool get isValid => location.isValid;

  /// Latitud (atajo)
  double get latitude => location.latitude;

  /// Longitud (atajo)
  double get longitude => location.longitude;

  /// Tiempo desde que se obtuvo la ubicación (texto amigable)
  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  //  MÉTODOS DE CONVERSIÓN

  /// Convertir a JSON (para guardar localmente)
  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crear una copia con nuevos datos
  UserLocation copyWith({Location? location, DateTime? timestamp}) {
    return UserLocation(
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // 5. DEBUG

  @override
  String toString() {
    return 'UserLocation(lat: $latitude, lng: $longitude, $timeAgo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLocation &&
        other.location == location &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => location.hashCode ^ timestamp.hashCode;
}
