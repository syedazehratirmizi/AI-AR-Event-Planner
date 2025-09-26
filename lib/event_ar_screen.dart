import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class EventARScreen extends StatefulWidget {
  final String modelName; // event-specific model name

  const EventARScreen({super.key, required this.modelName});

  @override
  State<EventARScreen> createState() => _EventARScreenState();
}

class _EventARScreenState extends State<EventARScreen> {
  CameraController? _cameraController;
  double _zoom = 1.0;
  double _rotationY = 0.0;
  final ScrollController _zoomController = ScrollController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _initCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _zoomController.addListener(() {
      setState(() {
        final raw = 0.5 + (_zoomController.offset / 200);
        _zoom = raw.clamp(0.5, 2.0);
      });
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(back, ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _zoomController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _shareScreenshot() async {
    final bytes = await _screenshotController.capture();
    if (bytes != null) {
      final file = XFile.fromData(
        bytes,
        name: 'ar_preview.png',
        mimeType: 'image/png',
      );
      await Share.shareXFiles([file],
          text: 'Check out this AR model: ${widget.modelName}');
    }
  }

  Future<void> _saveScreenshot() async {
    final Uint8List? bytes = await _screenshotController.capture();
    if (bytes == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${widget.modelName}_preview.png');
    await file.writeAsBytes(bytes);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to ${file.path}')),
    );
  }

  Widget _buildZoomBar() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        color: Colors.black54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView.builder(
              controller: _zoomController,
              scrollDirection: Axis.horizontal,
              itemCount: 100,
              itemBuilder: (context, index) {
                final isMajor = index % 5 == 0;
                return Container(
                  width: 20,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: isMajor ? 30 : 15,
                    width: 2,
                    color: Colors.white,
                  ),
                );
              },
            ),
            Container(width: 4, height: 40, color: Colors.red),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('AR View: ${widget.modelName}')),
      body: Screenshot(
        controller: _screenshotController,
        child: Stack(
          children: [
            CameraPreview(_cameraController!),
            Center(
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _rotationY += d.delta.dx * 0.5; // horizontal rotate
                  });
                },
                child: Transform.scale(
                  scale: _zoom,
                  child: Transform.rotate(
                    angle: _rotationY * 3.1416 / 180,
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: ModelViewer(
                        src: 'assets/models/${widget.modelName}.glb',
                        autoRotate: false,
                        disableZoom: true, // using our custom zoom
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildZoomBar(),
            Positioned(
              top: 20,
              right: 10,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _shareScreenshot,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _saveScreenshot,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
