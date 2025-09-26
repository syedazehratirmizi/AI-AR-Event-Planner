import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image/image.dart' as img;

class EventThemeDetectorScreen extends StatefulWidget {
  const EventThemeDetectorScreen({super.key});

  @override
  State<EventThemeDetectorScreen> createState() =>
      _EventThemeDetectorScreenState();
}

class _EventThemeDetectorScreenState extends State<EventThemeDetectorScreen> {
  File? selectedImage;
  File? processedImage;
  List<Color> themeColors = [];
  List<String> decorationImagesUrls = [];
  final picker = ImagePicker();
  bool isLoading = false;

  final String unsplashKey = 'your_access_key_here';

  Future<void> pickImage({required bool fromCamera}) async {
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        processedImage = null;
        themeColors = [];
        decorationImagesUrls = [];
      });

      await extractColors(File(picked.path));
      removeDominantColor();
      await fetchDecorations();
    }
  }

  Future<void> extractColors(File imageFile) async {
    final imageProvider = FileImage(imageFile);
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(200, 200),
      maximumColorCount: 5,
    );

    setState(() {
      themeColors = paletteGenerator.colors.toList();
    });
  }

  void removeDominantColor() {
    if (selectedImage == null || themeColors.isEmpty) return;

    Color dominantColor = themeColors.first;
    final bytes = selectedImage!.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return;

    final dr = dominantColor.r;
    final dg = dominantColor.g;
    final db = dominantColor.b;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final pr = pixel.r;
        final pg = pixel.g;
        final pb = pixel.b;

        if ((pr - dr).abs() < 50 &&
            (pg - dg).abs() < 50 &&
            (pb - db).abs() < 50) {
          image.setPixelRgba(x, y, 0, 0, 0, 0); // transparent
        }
      }
    }

    File newFile =
    File(selectedImage!.path)..writeAsBytesSync(img.encodePng(image));
    setState(() {
      processedImage = newFile;
    });
  }

  /// Fetch event decoration images (ignoring color filter)
  Future<void> fetchDecorations() async {
    setState(() {
      isLoading = true;
      decorationImagesUrls.clear();
    });

    final url = Uri.https(
      'api.unsplash.com',
      '/search/photos',
      {
        'query': 'wedding decoration OR birthday decoration OR party decoration OR event decoration',
        'per_page': '20',
        'orientation': 'landscape',
        'client_id': unsplashKey,
      },
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;

      for (var imgData in results) {
        final desc = (imgData['alt_description'] ?? '').toLowerCase();
        if (desc.contains('decor') ||
            desc.contains('wedding') ||
            desc.contains('birthday') ||
            desc.contains('party') ||
            desc.contains('event')) {
          decorationImagesUrls.add(imgData['urls']['small']);
        }
      }
    } else {
      debugPrint('Unsplash API Error: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildColorThemeRow() {
    if (themeColors.isEmpty) {
      return const Text(
        "Pick an image to detect event colors",
        style: TextStyle(fontSize: 16),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      children: themeColors.map((c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            Text(
              "#${c.value.toRadixString(16).substring(2).toUpperCase()}",
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget buildDecorationCarousel() {
    if (decorationImagesUrls.isEmpty) return const SizedBox();
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        viewportFraction: 0.6,
      ),
      items: decorationImagesUrls.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey, child: const Icon(Icons.error)),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Theme Detector"),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF4A4E69),
      ),
      backgroundColor: const Color(0xFFC9ADA7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(selectedImage!, height: 220, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            if (processedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(processedImage!, height: 220, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            buildColorThemeRow(),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : buildDecorationCarousel(),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickImage(fromCamera: false),
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => pickImage(fromCamera: true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
