import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/map_screen.dart';
import 'viewmodels/map_viewmodel.dart';
import 'viewmodels/filter_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => FilterViewModel()),
      ],
      child: MaterialApp(
        title: 'Eventos Cercanos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Modern Indigo
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF8B5CF6), // Violet
            tertiary: const Color(0xFF06B6D4), // Cyan
            surface: Colors.white,
            error: const Color(0xFFEF4444),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light Slate
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0F172A), // Dark Slate
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF475569)),
            actionsIconTheme: IconThemeData(color: Color(0xFF475569)),
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: const Color(0xFF6366F1),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: const Color(0xFF6366F1),
            overlayColor: const Color(0xFF6366F1).withOpacity(0.12),
            valueIndicatorColor: const Color(0xFF0F172A),
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            showValueIndicator: ShowValueIndicator.always,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIconColor: const Color(0xFF64748B),
            suffixIconColor: const Color(0xFF64748B),
          ),
        ),
        home: const MapScreen(),
      ),
    );
  }
}
