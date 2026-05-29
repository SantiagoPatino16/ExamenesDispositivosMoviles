import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FilterViewModel extends ChangeNotifier {
  String? _selectedCity;
  String? _selectedCategory;
  String? _searchKeyword;
  double _radius = 5;

  // Controller para limpiar el TextField visualmente
  final TextEditingController keywordController = TextEditingController();

  String? get selectedCity => _selectedCity;
  String? get selectedCategory => _selectedCategory;
  String? get searchKeyword => _searchKeyword;
  double get radius => _radius;

  void setCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setKeyword(String? keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setRadius(double radius) {
    _radius = radius;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCity = null;
    _selectedCategory = null;
    _searchKeyword = null;
    _radius = 5;
    keywordController.clear(); // Limpia el texto visualmente
    notifyListeners();
  }

  @override
  void dispose() {
    keywordController.dispose();
    super.dispose();
  }
}
