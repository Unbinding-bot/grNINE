import 'package:flutter/material.dart';

class TDSDataProvider extends ChangeNotifier {
  double _currentTDS = 0.0;
  DateTime? _lastUpdated;
  List<Map<String, dynamic>> _tdsHistory = [];

  double get currentTDS => _currentTDS;
  DateTime? get lastUpdated => _lastUpdated;
  List<Map<String, dynamic>> get tdsHistory => _tdsHistory;

  Future<void> loadTDSData() async {
    // Load from local storage or sensor
    // This is a placeholder
    notifyListeners();
  }

  void addTDSReading(double value) {
    _currentTDS = value;
    _lastUpdated = DateTime.now();
    _tdsHistory.add({
      'value': value,
      'timestamp': _lastUpdated,
    });
    notifyListeners();
  }

  void setTDSHistory(List<Map<String, dynamic>> history) {
    _tdsHistory = history;
    if (_tdsHistory.isNotEmpty) {
      _currentTDS = _tdsHistory.last['value'] as double;
      _lastUpdated = _tdsHistory.last['timestamp'] as DateTime?;
    }
    notifyListeners();
  }

  void clearHistory() {
    _tdsHistory.clear();
    _currentTDS = 0.0;
    _lastUpdated = null;
    notifyListeners();
  }
}