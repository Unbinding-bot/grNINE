import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/tds_data_provider.dart';

class FileService {
  Future<void> importTDSFile(TDSDataProvider tdsProvider) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      _parseTDSData(content, tdsProvider);
    }
  }

  void _parseTDSData(String content, TDSDataProvider tdsProvider) {
    List<Map<String, dynamic>> tdsData = [];

    final lines = content.split('\n');
    for (var line in lines) {
      if (line.isEmpty) continue;

      try {
        // Support CSV format: timestamp,tds_value
        // Support JSON format: {"timestamp": "...", "value": ...}
        if (line.startsWith('{')) {
          // JSON format
          final parts = line.split(',');
          for (var part in parts) {
            if (part.contains('value')) {
              final value = double.parse(
                part.split(':')[1].replaceAll('"', '').replaceAll('}', ''),
              );
              tdsData.add({
                'value': value,
                'timestamp': DateTime.now(),
              });
            }
          }
        } else {
          // CSV format
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