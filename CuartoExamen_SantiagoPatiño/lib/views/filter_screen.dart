import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/filter_viewmodel.dart';
import '../viewmodels/map_viewmodel.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros Avanzados'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<FilterViewModel>().clearFilters();
            },
            child: const Text(
              'Limpiar todo',
              style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Consumer<FilterViewModel>(
        builder: (context, filterVM, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // --- RADIO DE BÚSQUEDA ---
              _buildSectionHeader('Radio de búsqueda', Icons.radar_outlined),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distancia máxima',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filterVM.radius.round()} km',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: filterVM.radius,
                min: 5,
                max: 50,
                divisions: 9,
                label: '${filterVM.radius.round()} km',
                onChanged: (value) => filterVM.setRadius(value),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF1F5F9), height: 32),

              // --- CIUDAD ---
              _buildSectionHeader('Ciudad', Icons.location_city_outlined),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: filterVM.selectedCity,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_city_outlined),
                  hintText: 'Todas',
                ),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todas')),
                  DropdownMenuItem(value: 'Medellin', child: Text('Medellín')),
                  DropdownMenuItem(value: 'Bogota', child: Text('Bogotá')),
                  DropdownMenuItem(value: 'Cali', child: Text('Cali')),
                  DropdownMenuItem(value: 'New York', child: Text('New York')),
                ],
                onChanged: (value) => filterVM.setCity(value),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF1F5F9), height: 32),

              // --- CATEGORÍA ---
              _buildSectionHeader('Categoría', Icons.category_outlined),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: filterVM.selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                  hintText: 'Todas',
                ),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todas')),
                  DropdownMenuItem(value: 'music', child: Text('Música')),
                  DropdownMenuItem(value: 'sports', child: Text('Deportes')),
                  DropdownMenuItem(value: 'arts', child: Text('Artes')),
                ],
                onChanged: (value) => filterVM.setCategory(value),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF1F5F9), height: 32),

              // --- PALABRA CLAVE ---
              _buildSectionHeader('Palabra clave', Icons.tag_outlined),
              const SizedBox(height: 8),
              TextField(
                controller: filterVM.keywordController,
                onChanged: (value) => filterVM.setKeyword(
                  value.trim().isEmpty ? null : value.trim(),
                ),
                decoration: const InputDecoration(
                  hintText: 'Ej: Rock, Festival, Jazz',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 36),

              // --- BOTÓN APLICAR ---
              ElevatedButton.icon(
                onPressed: () {
                  final mapVM = context.read<MapViewModel>();
                  mapVM.applyFilters(
                    city: filterVM.selectedCity,
                    category: filterVM.selectedCategory,
                    keyword: filterVM.searchKeyword,
                    radius: filterVM.radius,
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: const Text('Aplicar filtros'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6366F1)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
