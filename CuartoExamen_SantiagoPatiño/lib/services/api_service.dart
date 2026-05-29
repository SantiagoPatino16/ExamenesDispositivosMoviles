
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

/// Servicio para comunicarse con la API de Ticketmaster
class TicketmasterService {
  // 1. CONSTANTES

  static const String baseUrl = 'https://app.ticketmaster.com/discovery/v2';
  static const String apiKey = 'NAjGRnFcr6ZM739u443Guy42smnugZYY';

  // MÉTODOS PRINCIPALES

  /// [lat] - Latitud del usuario
  /// [lng] - Longitud del usuario
  /// [radius] - Radio en kilómetros (mínimo 5km según el examen)
  /// [keyword] - Palabra clave opcional para filtrar
  /// [city] - Ciudad opcional para filtrar
  /// [category] - Categoría opcional (deportes, musica, etc.)
  Future<List<Event>> searchEvents({
    required double lat,
    required double lng,
    double radius = 5, // Mínimo 5km
    String? keyword,
    String? city,
    String? category,
  }) async {
    try {
      // Construir la URL con los parámetros
      final url = _buildUrl(
        lat: lat,
        lng: lng,
        radius: radius,
        keyword: keyword,
        city: city,
        category: category,
      );

      print('Llamando a API: $url'); // Para debugging

      // Hacer la petición
      final response = await http.get(Uri.parse(url));

      // Verificar respuesta
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseEventsResponse(data);
      } else {
        throw Exception('Error al cargar eventos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en API: $e');
      return []; // Retornar lista vacía en caso de error
    }
  }

  /// Buscar eventos por ciudad específica
  Future<List<Event>> searchEventsByCity(String city) async {
    try {
      final url = '$baseUrl/events.json?apikey=$apiKey&city=$city';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseEventsResponse(data);
      } else {
        throw Exception('Error al cargar eventos de $city');
      }
    } catch (e) {
      print('Error en API por ciudad: $e');
      return [];
    }
  }

  /// Buscar eventos por categoría
  Future<List<Event>> searchEventsByCategory(String category) async {
    try {
      final url =
          '$baseUrl/events.json?apikey=$apiKey&classificationName=$category';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseEventsResponse(data);
      } else {
        throw Exception('Error al cargar eventos de categoría $category');
      }
    } catch (e) {
      print('Error en API por categoría: $e');
      return [];
    }
  }

  //MÉTODOS PRIVADOS

  /// Construir la URL con todos los parámetros
  String _buildUrl({
    required double lat,
    required double lng,
    required double radius,
    String? keyword,
    String? city,
    String? category,
  }) {
    // Parámetros base
    final params = <String, String>{
      'apikey': apiKey,
      'latlong': '$lat,$lng',
      'radius': radius.toString(),
      'unit': 'km', // Unidad en kilómetros
      'sort': 'date,asc', // Ordenar por fecha
    };

    // Agregar parámetros opcionales si existen
    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }
    if (city != null && city.isNotEmpty) {
      params['city'] = city;
    }
    if (category != null && category.isNotEmpty) {
      params['classificationName'] = category;
    }

    // Construir la URL
    final queryString = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return '$baseUrl/events.json?$queryString';
  }

  /// Parsear la respuesta JSON a una lista de Eventos
  List<Event> _parseEventsResponse(Map<String, dynamic> data) {
    final events = <Event>[];

    // La API devuelve los eventos dentro de _embedded.events
    final embedded = data['_embedded'] as Map<String, dynamic>?;
    final eventsList = embedded?['events'] as List?;

    if (eventsList == null || eventsList.isEmpty) {
      print('No se encontraron eventos');
      return events;
    }

    // Convertir cada evento JSON a objeto Event
    for (final eventJson in eventsList) {
      try {
        final event = Event.fromJson(eventJson);
        // Solo agregar eventos con coordenadas válidas
        if (event.hasValidCoordinates) {
          events.add(event);
        }
      } catch (e) {
        print('Error al parsear evento: $e');
      }
    }

    print('Se cargaron ${events.length} eventos');
    return events;
  }

  // 4. MÉTODO PARA VERIFICAR LA API KEY

  /// Verificar que la API Key es válida
  Future<bool> validateApiKey() async {
    try {
      final url = '$baseUrl/events.json?apikey=$apiKey&size=1';
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
