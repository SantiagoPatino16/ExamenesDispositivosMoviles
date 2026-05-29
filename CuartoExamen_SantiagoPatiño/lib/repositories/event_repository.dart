import '../models/event.dart';
import '../models/user_location.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class EventRepository {
  final TicketmasterService _apiService = TicketmasterService();
  final LocationService _locationService = LocationService();

  Future<({List<Event> events, UserLocation? userLocation})> getNearbyEvents({
    double radiusKm = 5,
  }) async {
    try {
      final userLocation = await _locationService.getCurrentLocation();

      if (userLocation == null) {
        return (events: <Event>[], userLocation: null);
      }

      final events = await _apiService.searchEvents(
        lat: userLocation.latitude,
        lng: userLocation.longitude,
        radius: radiusKm,
      );

      return (events: events, userLocation: userLocation);
    } catch (e) {
      print('Error: $e');
      return (events: <Event>[], userLocation: null);
    }
  }

  Future<bool> validateApiKey() async {
    return await _apiService.validateApiKey();
  }

  Future<bool> isLocationAvailable() async {
    return await _locationService.checkLocationPermission();
  }
}
