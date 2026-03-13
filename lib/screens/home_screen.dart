import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tds_data_provider.dart';
import '../widgets/tds_display.dart';
import '../widgets/tds_graph.dart';
import '../services/file_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TDSDataProvider>().loadTDSData();
    });
  }

  Future<void> _importTDSFile() async {
    try {
      await _fileService.importTDSFile(context.read<TDSDataProvider>());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TDS data imported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TDS Monitor'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Large TDS Display
              const TDSDisplay(),
              const SizedBox(height: 32),
              // Historical Graph
              const Text(
                'TDS Historical Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TDSGraph(),
              const SizedBox(height: 24),
              // Import Button
              ElevatedButton.icon(
                onPressed: _importTDSFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Import TDS Data'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
