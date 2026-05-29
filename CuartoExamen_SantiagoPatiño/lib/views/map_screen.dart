import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../viewmodels/map_viewmodel.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';
import 'filter_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  LatLng? _userLocation;

  static const LatLng _initialPosition = LatLng(40.7128, -74.0060);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();

      // Listener: cada vez que el MapViewModel notifique cambios,
      // actualizar los marcadores automáticamente
      context.read<MapViewModel>().addListener(_onViewModelChanged);
    });
  }

  @override
  void dispose() {
    context.read<MapViewModel>().removeListener(_onViewModelChanged);
    super.dispose();
  }

  /// Se ejecuta automáticamente cuando el MapViewModel cambia
  void _onViewModelChanged() {
    final viewModel = context.read<MapViewModel>();
    if (!viewModel.isLoading) {
      _updateMarkers(viewModel.events);
    }
  }

  Future<void> _loadEvents() async {
    final viewModel = context.read<MapViewModel>();
    await viewModel.loadNearbyEvents();
    _updateMarkers(viewModel.events);
  }

  void _updateMarkers(List<Event> events) {
    final userLocation = context.read<MapViewModel>().userLocation;

    setState(() {
      _markers.clear();

      for (final event in events) {
        if (event.hasValidCoordinates) {
          final marker = Marker(
            width: 80,
            height: 80,
            point: LatLng(event.latitude, event.longitude),
            child: GestureDetector(
              onTap: () => _showEventDetails(event),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Globo del marcador con el precio
                  Container(
                    decoration: BoxDecoration(
                      color: _getMarkerColor(event),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      event.isFree
                          ? 'Gratis'
                          : (event.minPrice != null
                              ? '\$${event.minPrice!.toStringAsFixed(0)}'
                              : 'Ver'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Punto de ubicación central debajo del globo
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Nombre abreviado del evento
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxWidth: 76),
                    child: Text(
                      event.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
          _markers.add(marker);
        }
      }

      if (userLocation != null) {
        _userLocation = LatLng(userLocation.latitude, userLocation.longitude);

        final userMarker = Marker(
          width: 50,
          height: 50,
          point: _userLocation!,
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Halo de pulso
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                // Círculo exterior blanco
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // Punto central azul
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
        _markers.add(userMarker);

        _mapController.move(_userLocation!, 13);
      }
    });
  }

  Color _getMarkerColor(Event event) {
    if (event.isFree) return const Color(0xFF10B981); // Emerald Green
    if (event.minPrice != null && event.minPrice! < 50) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Coral Red
  }

  void _showEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
    );
  }

  void _showFilterDialog() {
    final viewModel = context.read<MapViewModel>();
    double selectedRadius = viewModel.currentRadius;

    showDialog(
      context: context,
      builder: (context) {
        double tempRadius = selectedRadius;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.radar,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filtrar eventos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Radio de búsqueda (km)',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: tempRadius,
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '${tempRadius.round()} km',
                    onChanged: (value) {
                      setDialogState(() {
                        tempRadius = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.setRadius(tempRadius);
                          Navigator.pop(context);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //Interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Scaffold
      appBar: AppBar(
        //AppBar
        title: const Text('Eventos Cercanos'),
        centerTitle: true,
        actions: [
          // Botón de filtros avanzados (Ciudad, Categoría, Palabra clave)
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FilterScreen()),
              );
            },
            tooltip: 'Filtros avanzados',
          ),
          // Botón de filtrar por radio
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar por radio',
          ),
          // Botón de recargar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadEvents(),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Consumer<MapViewModel>(
        //Body
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), //CircularProgressIndicator
                  SizedBox(height: 16),
                  Text('Buscando eventos cerca de ti...'),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadEvents(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            //Stack
            children: [
              // Mapa
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialPosition,
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(markers: _markers),
                ],
              ),

              // Lista horizontal de eventos en la parte inferior
              if (viewModel.hasEvents)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    height: 135,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: viewModel.events.length,
                      itemBuilder: (context, index) {
                        final event = viewModel.events[index];
                        return GestureDetector(
                          onTap: () => _showEventDetails(event),
                          child: Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 12, bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (event.imageUrl != null)
                                        Image.network(
                                          event.imageUrl!,
                                          height: 75,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 75,
                                            color: const Color(0xFFF1F5F9),
                                            child: const Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Color(0xFF94A3B8),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                event.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 11,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      event.venueName,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Badge de precio flotante en la esquina superior derecha
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: event.isFree
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF6366F1).withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        event.isFree ? 'Gratis' : event.priceText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Mensaje cuando no hay eventos
              if (!viewModel.hasEvents && !viewModel.isLoading)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay eventos en esta área'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
