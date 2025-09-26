import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';
import 'ar_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController controller = TextEditingController();
  bool isInputEmpty = true;

  final List<String> models = [
    'adult-birthday-theme','babyshower-lowbudget','beach-wedding','birthday-blue','blue-decoration',
    'corporate-event','day-wedding-theme','decent-wedding-decor','default','engagement',
    'graden-pink-wedding','grand-birthday-party','green-decor','home-engagement','indoor-wedding-decor',
    'indoor-wedding-lavendor','lowbudget-wedding-theme','mahendi-decor','meyon-garden','outdoor-engagement',
    'pink-birthday-theme','pink-arch-wedding','pink-birthday','purpose-decor','red-rose-heart-decor',
    'red-rose-wedding','romantic-candellight-dinner','rustic-grand-wedding','simple-wall-decor','trending-theme',
    'valentine-decor','western-decor','white-golden-birthday','babyshower-boy-decoration','babyshower-skyblue-decor',
    'black-golden-birthday-decor','bridalshower-decor-orange','graduation-blue-decoration','graduation-decoration-green',
    'mehndi-orange-decoration','office-annual-event-decoration','outdoor-nikkah-decoration-whiterose',
    'pink-bridalshower-decoration','pink-engagement-decoration','qawwali-night-wedding-decoration',
    'Burgundy-gold-birthday-decoration','purple-decoration-valima','baat-paki-decoration',
    'gray-white-bridalshower-decoration','bridalshower-beigen-cream','silver-pastelblue-decoration',
    'babyshower-white-pink','green-white-decoration','girl-babyshower-pink-decoration','nikaah-decoration-red-rose',
    'Burgundy-gold-valima-decoration','pastel-valima-decoration-outdoor','brid-to-be-decoration',
    'light-pink-valima-decoration','yellow-mayoun-decoration','burgundy-valima-decoration',
    'engagement-purple-theme','forest-wedding-decor','garden-baby-shower','light-pastel-color-decoration',
    'mayoun-garden','outdoor-nikkah-decor','outdoor-pink-decoration','purple-birthday-decor','roof-mehndi-decoration',
  ];

  List<String> suggestions = [];

  void _updateSuggestions(String input) {
    setState(() {
      isInputEmpty = input.trim().isEmpty;
      if (input.trim().isEmpty) {
        suggestions.clear();
        return;
      }

      var matches = models.map((m) {
        double score = StringSimilarity.compareTwoStrings(
          input.toLowerCase(),
          m.toLowerCase(),
        );
        return {'model': m, 'score': score};
      }).toList();

      matches.sort((a, b) =>
          (b['score'] as double).compareTo(a['score'] as double));
      suggestions = matches.take(3).map((e) => e['model'] as String).toList();
      if (suggestions.isEmpty) suggestions = (models..shuffle()).take(3).toList();
    });
  }

  void _selectSuggestion(String text) {
    controller.text = text;
    setState(() {
      isInputEmpty = text.trim().isEmpty;
      suggestions.clear();
    });
  }

  Future<void> _openARScreen() async {
    String query = controller.text.trim();
    if (query.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A4E69)),
      ),
    );

    String modelUrl = '';
    try {
      final uri = Uri.parse(
        'Your_Hugging_Face_API_Endpoint_Here', // Replace with your actual endpoint
      );

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": [query]}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        modelUrl = data['data'][0]?.toString() ?? '';
      }
    } catch (e) {
      debugPrint("Hugging Face API error: $e");
    }

    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (modelUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ARScreen(modelUrl: modelUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate 3D model.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9ADA7),
      appBar: AppBar(
        title: const Text(
          'Chatbot Assistant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A4E69),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: _updateSuggestions,
              decoration: InputDecoration(
                labelText: 'Enter decoration type',
                labelStyle: const TextStyle(color: Color(0xFF4A4E69)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF4A4E69)),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 8),
            if (suggestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black26.withOpacity(0.1), blurRadius: 4)
                  ],
                ),
                child: Column(
                  children: suggestions.map((s) {
                    return ListTile(
                      dense: true,
                      title: Text(s, style: const TextStyle(color: Colors.black87)),
                      onTap: () => _selectSuggestion(s),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              onPressed: isInputEmpty ? null : _openARScreen,
              label: const Text('Generate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4E69),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
