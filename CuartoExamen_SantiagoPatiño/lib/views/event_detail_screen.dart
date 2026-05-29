import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewmodels/event_detail_viewmodel.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventDetailViewModel(event: event),
      child: Scaffold(
        body: Consumer<EventDetailViewModel>(
          builder: (context, viewModel, child) {
            return NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 240.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    // Botón de regresar con fondo circular semitransparente
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                            Image.network(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          // Gradiente sutil inferior sobre la imagen
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                                positions: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del evento
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tarjetas de detalles
                      _buildInfoCard(
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFF6366F1), // Indigo
                        label: 'Fecha y Hora',
                        value: event.formattedDate,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.confirmation_number_outlined,
                        iconColor: const Color(0xFF8B5CF6), // Violet
                        label: 'Precio aproximado',
                        value: event.priceText,
                        valueColor: event.isFree ? const Color(0xFF10B981) : null,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.place_outlined,
                        iconColor: const Color(0xFF06B6D4), // Cyan
                        label: 'Lugar / Establecimiento',
                        value: event.venueName,
                      ),
                      const SizedBox(height: 12),

                      if (event.city != null || event.country != null) ...[
                        _buildInfoCard(
                          icon: Icons.map_outlined,
                          iconColor: const Color(0xFF64748B),
                          label: 'Ubicación',
                          value: event.locationText,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Botones de acción en fila
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openMap(),
                              icon: const Icon(Icons.directions_outlined, size: 18),
                              label: const Text('Cómo llegar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE0E7FF), // Soft Indigo
                                foregroundColor: const Color(0xFF6366F1),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          if (event.url != null && event.url!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _buyTickets(),
                                icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                                label: const Text('Comprar boletos'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981), // Emerald Green
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: const Color(0xFF10B981).withOpacity(0.3),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (viewModel.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
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
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openMap() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir el mapa');
    }
  }

  void _buyTickets() async {
    if (event.url != null) {
      final uri = Uri.parse(event.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
