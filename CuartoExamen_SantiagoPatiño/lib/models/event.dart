//Modelo que representara un evento obtenido de la API de Ticketmaster

import 'package:flutter/foundation.dart';

class Event {
  //Informacion basica
  final String id; //Identificador unico del evento
  final String name; //Nombre del evento (ej; "Rock Festival")

  //Ubicacion para el mapa
  final double latitude; //Longitud
  final double longitude; //Latitud
  final String venueName; //Nombre del lugar

  //Multimedia
  final String? imageUrl; //URL de la imagen del evento

  //Fechas
  final DateTime? date; //Fecha del evento

  //Precios
  final double? minPrice; //Precio minimo
  final double? maxPrice; //Precio maximo

  //Ubicacion geografica
  final String? city; //ciudad
  final String? country; //pais

  //enlaces
  final String? url; //URL para poder comprar boletas

  //Constructor para crear los eventos
  Event({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.venueName,
    this.imageUrl,
    this.date,
    this.minPrice,
    this.maxPrice,
    this.city,
    this.country,
    this.url,
  });

  //Creamos una factory para crear un event desde JSON (lo que devuelve el TicketMaster) / Recibe lo que trae la API y lo ordena

  factory Event.fromJson(Map<String, dynamic> json) {
    // --- 3.1 Extraer el venue (lugar) del JSON anidado ---

    // Busca donde esta el lugar del evento
    final embedded =
        json['_embedded']
            as Map<String, dynamic>?; //_embedded (cosas que estan adentro)
    final venues = embedded?['venues'] as List?; //Lugares
    final venue = (venues != null && venues.isNotEmpty) ? venues[0] : null;

    // Extrae las coordenadas de dicho evento
    final location = venue?['location'] as Map<String, dynamic>?;
    double lat = 0.0;
    double lng = 0.0;

    if (location != null) {
      lat = double.tryParse(location['latitude']?.toString() ?? '0') ?? 0.0;
      lng = double.tryParse(location['longitude']?.toString() ?? '0') ?? 0.0;
    }

    // Extrae las fechas de dicho evento
    final dates = json['dates'] as Map<String, dynamic>?;
    final start = dates?['start'] as Map<String, dynamic>?;
    final dateString = start?['localDate'] as String?;
    DateTime? eventDate;
    if (dateString != null) {
      eventDate = DateTime.tryParse(dateString);
    }

    // Extrae los precios del evento
    final priceRanges = json['priceRanges'] as List?;
    double? minPrice;
    double? maxPrice;
    if (priceRanges != null && priceRanges.isNotEmpty) {
      final firstRange = priceRanges[0] as Map<String, dynamic>;
      minPrice = firstRange['min']?.toDouble();
      maxPrice = firstRange['max']?.toDouble();
    }

    // Extrae la imagen
    final images = json['images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      // Buscar imagen de tamaño mediano (640px) o tomar la primera
      final image = images.firstWhere(
        (img) => img['width'] == 640,
        orElse: () => images[0],
      );
      imageUrl = image['url'] as String?;
    }

    // Extrae la ciudad y el pais
    final city = venue?['city']?['name'] as String?;
    final country = venue?['country']?['name'] as String?;

    // Crea el objeto segun los datos extradios
    return Event(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Evento sin nombre',
      latitude: lat,
      longitude: lng,
      venueName: venue?['name'] ?? 'Lugar no especificado',
      imageUrl: imageUrl,
      date: eventDate,
      minPrice: minPrice,
      maxPrice: maxPrice,
      city: city,
      country: country,
      url: json['url'] as String?,
    );
  }

  //El metodo que convierte event a json (para guardar localmente)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'venueName': venueName,
      'imageUrl': imageUrl,
      'date': date?.toIso8601String(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'city': city,
      'country': country,
      'url': url,
    };
  }

  //Propiedades calculadas

  //Texto formateado del precio
  String get priceText {
    if (minPrice == null) return 'Precio no disponible';
    if (minPrice == 0) return 'GRATIS';
    if (maxPrice == null) return '\$${minPrice!.toStringAsFixed(0)}';
    return '\$${minPrice!.toStringAsFixed(0)} - \$${maxPrice!.toStringAsFixed(0)}';
  }

  // Texto formateado de la fecha (ej: "15/05/2026")
  String get formattedDate {
    if (date == null) return 'Fecha por confirmar';
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  /// Texto de ubicación (ej: "Medellín, Colombia" o solo "Estadio")
  String get locationText {
    if (city != null && country != null) return '$city, $country';
    if (city != null) return city!;
    if (country != null) return country!;
    return venueName;
  }

  /// ¿Es un evento gratuito?
  bool get isFree => minPrice == 0;

  /// ¿Tiene coordenadas válidas? (no son 0,0)
  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;

  //Metodos
  /// Crear una copia del evento con algunos campos modificados
  Event copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? venueName,
    String? imageUrl,
    DateTime? date,
    double? minPrice,
    double? maxPrice,
    String? city,
    String? country,
    String? url,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      venueName: venueName ?? this.venueName,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      city: city ?? this.city,
      country: country ?? this.country,
      url: url ?? this.url,
    );
  }

  /// Para debugging (mostrar en consola)
  @override
  String toString() {
    return 'Event(id: $id, name: $name, location: $locationText, date: $formattedDate)';
  }

  /// Para comparar dos eventos (por ID)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
