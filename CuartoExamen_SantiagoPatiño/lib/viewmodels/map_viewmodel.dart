import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/user_location.dart';
import '../repositories/event_repository.dart';
import '../services/api_service.dart';

class MapViewModel extends ChangeNotifier {
  final EventRepository _repository = EventRepository();
  final TicketmasterService _apiService = TicketmasterService();

  List<Event> _events = [];
  UserLocation? _userLocation;
  bool _isLoading = false;
  String? _errorMessage;
  double _currentRadius = 5;

  List<Event> get events => _events;
  UserLocation? get userLocation => _userLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get currentRadius => _currentRadius;
  bool get hasEvents => _events.isNotEmpty;

  Future<void> loadNearbyEvents({double? radiusKm}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (radiusKm != null) _currentRadius = radiusKm;

    try {
      final result = await _repository.getNearbyEvents(
        radiusKm: _currentRadius,
      );
      _events = result.events;
      _userLocation = result.userLocation;

      if (_events.isEmpty && _userLocation != null) {
        _errorMessage = 'No hay eventos en un radio de ${_currentRadius}km';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    String? city,
    String? category,
    String? keyword,
    double? radius,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (radius != null) _currentRadius = radius;

      // Caso 1: Filtrar por ciudad
      if (city != null && city.isNotEmpty) {
        _events = await _apiService.searchEventsByCity(city);
        _userLocation = null;
      }
      // Caso 2: Filtrar por categoría
      else if (category != null && category.isNotEmpty) {
        if (_userLocation != null) {
          _events = await _apiService.searchEvents(
            lat: _userLocation!.latitude,
            lng: _userLocation!.longitude,
            radius: _currentRadius,
            category: category,
          );
        } else {
          _events = await _apiService.searchEventsByCategory(category);
        }
      }
      // Caso 3: Filtrar por palabra clave
      else if (keyword != null && keyword.isNotEmpty) {
        if (_userLocation != null) {
          _events = await _apiService.searchEvents(
            lat: _userLocation!.latitude,
            lng: _userLocation!.longitude,
            radius: _currentRadius,
            keyword: keyword,
          );
        } else {
          _errorMessage = 'Se necesita ubicación para buscar por palabra clave';
          _events = [];
        }
      }
      // Caso 4: Sin filtros (Todas / Todas) → recarga eventos normales desde cero
      else {
        // Siempre recarga desde el repositorio, no depende de _userLocation guardado
        final result = await _repository.getNearbyEvents(
          radiusKm: _currentRadius,
        );
        _events = result.events;
        _userLocation = result.userLocation;

        if (_events.isEmpty && _userLocation == null) {
          _errorMessage = 'No se pudo obtener la ubicación para buscar eventos';
        } else if (_events.isEmpty) {
          _errorMessage = 'No hay eventos en un radio de ${_currentRadius}km';
        }
        // Si encontró eventos, no hay error — retorna aquí
        return;
      }

      if (_events.isEmpty && _errorMessage == null) {
        _errorMessage = 'No se encontraron eventos con esos filtros';
      }
    } catch (e) {
      _errorMessage = 'Error al aplicar filtros: $e';
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEvents() async {
    await loadNearbyEvents(radiusKm: _currentRadius);
  }

  void setRadius(double newRadius) {
    _currentRadius = newRadius;
    notifyListeners();
    loadNearbyEvents(radiusKm: newRadius);
  }
}
