import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'favorites.dart';
import 'event_ar_screen.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({Key? key}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Map<String, String> event;
  bool isFavorited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    event = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    isFavorited = favoriteEvents.value.any((e) => e['name'] == event['name']);
  }

  void toggleFavorite() {
    setState(() {
      if (isFavorited) {
        favoriteEvents.value.removeWhere((e) => e['name'] == event['name']);
      } else {
        favoriteEvents.value.add(event);
      }
      isFavorited = !isFavorited;
      favoriteEvents.notifyListeners(); // Notify the change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full-screen image
          Positioned.fill(
            child: Image.asset(
              event['image']!,
              fit: BoxFit.cover,
            ),
          ),

          // Top buttons
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Favorite button
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: toggleFavorite,
                  ),
                ),
              ],
            ),
          ),

          // Bottom info container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    event['description'] ??
                        'Royal groom entrance and stage setup. Choose a wedding event and explore beautiful AR setups.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  const Text('Vendor Suggestion', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Our AI AR Event app suggests some best vendors for your event. ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Click Here',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/vendors');
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final modelName = event['modelName'];
                        if (modelName == null || modelName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No modelName found for this event')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventARScreen(modelName: modelName),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3D55),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Start With AR"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
