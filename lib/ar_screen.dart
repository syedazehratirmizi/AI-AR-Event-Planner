import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ARScreen extends StatefulWidget {
  final String modelUrl;
  const ARScreen({super.key, required this.modelUrl});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareScreenshot() async {
    final bytes = await _screenshotController.capture();
    if (bytes != null) {
      final file = XFile.fromData(bytes, name: 'ar_preview.png', mimeType: 'image/png');
      await Share.shareXFiles([file], text: 'Check out this AR model!');
    }
  }

  Future<void> _saveScreenshot() async {
    final Uint8List? bytes = await _screenshotController.capture();
    if (bytes == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ar_preview.png');
    await file.writeAsBytes(bytes);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
        backgroundColor: const Color(0xFF4A4E69),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareScreenshot),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveScreenshot),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Center(
          child: ModelViewer(
            src: widget.modelUrl,
            alt: '3D model',
            autoRotate: true,
            cameraControls: true,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
