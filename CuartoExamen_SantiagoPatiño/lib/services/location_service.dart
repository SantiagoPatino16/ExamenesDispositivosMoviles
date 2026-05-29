import 'package:geolocator/geolocator.dart';
import '../models/location.dart';
import '../models/user_location.dart';

class LocationService {
  /// Obtener la ubicación actual del usuario
  Future<UserLocation?> getCurrentLocation() async {
    try {
      // Verificar si los servicios de ubicación están activos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Servicios de ubicación desactivados');
        return null;
      }

      // Verificar y solicitar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print('Permisos de ubicación denegados');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permisos de ubicación denegados permanentemente');
        return null;
      }

      // Obtener posición real del dispositivo/emulador
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Actualizar cada 10 metros
        ),
      );

      print('Ubicación obtenida: ${position.latitude}, ${position.longitude}');
      return UserLocation.fromCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // Fallback a New York para pruebas en emulador sin GPS configurado
      print('Error al obtener ubicación: $e');
      print('Usando ubicación de respaldo: New York');
      return UserLocation.fromCoordinates(40.7128, -74.0060);
    }
  }

  /// Verificar permisos de ubicación
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Obtener ubicación en tiempo real
  Stream<UserLocation> getLocationStream() async* {
    await for (Position position in Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    )) {
      yield UserLocation.fromCoordinates(position.latitude, position.longitude);
    }
  }
}
