import 'dart:io';
import '../providers/tds_data_provider.dart';

class FileService {
  // Simple CSV parsing without file_picker plugin
  void parseTDSFromString(String content, TDSDataProvider tdsProvider) {
    List<Map<String, dynamic>> tdsData = [];

    final lines = content.split('\n');
    for (var line in lines) {
      if (line.isEmpty || line.startsWith('#')) continue;

      try {
        // CSV format: timestamp,tds_value
        final parts = line.split(',');
        if (parts.length >= 2) {
          try {
            final timestamp = DateTime.parse(parts[0].trim());
            final value = double.parse(parts[1].trim());
            tdsData.add({
              'value': value,
              'timestamp': timestamp,
            });
          } catch (e) {
            // Skip invalid lines
          }
        }
      } catch (e) {
        print('Error parsing line: $line, Error: $e');
      }
    }

    if (tdsData.isNotEmpty) {
      tdsProvider.setTDSHistory(tdsData);
    }
  }
}