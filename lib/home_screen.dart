import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_category_screen.dart';
import 'color_detection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Loading..."; // default text while fetching

  final List<Map<String, String>> categories = [
    {'label': 'Wedding', 'image': 'assets/cat_wedding.png'},
    {'label': 'Birthday', 'image': 'assets/cat_birthday.jpg'},
    {'label': 'Corporate', 'image': 'assets/cat_corporate.png'},
    {'label': 'Festival', 'image': 'assets/cat_festival.png'},
    {'label': 'WestEvent', 'image': 'assets/graden.jpg'},
  ];

  final List<Map<String, String>> weddingEvents = [
    {'name': 'Baraat Ceremony', 'image': 'assets/baraat.jpg', 'description': 'Traditional wedding procession', 'modelName': 'green-decor'},
    {'name': 'Engagement', 'image': 'assets/engagement.jpg', 'description': 'Ring exchange ceremony', 'modelName': 'graden-pink-wedding'},
  ];

  final List<Map<String, String>> birthdayEvents = [
    {'name': 'Burgundy Birthday', 'image': 'assets/birthday2.jpg', 'description': 'Burgundy Birthday theme', 'modelName': 'Burgundy-gold-birthday-decoration'},
    {'name': 'Lightcolor theme', 'image': 'assets/happy-birthday.jpg', 'description': 'Light Color Birthday Theme', 'modelName': 'adult-birthday-theme'},
  ];

  final List<Map<String, String>> corporateEvents = [
    {'name': 'Annual Meet', 'image': 'assets/coporate.jpg', 'description': 'Corporate Annual Meet or aniversary', 'modelName': 'office-annual-event-decoration'},
    {'name': 'graduation decor', 'image': 'assets/graduation.jpg', 'description': 'Corporate yearly meeting', 'modelName': 'graduation-blue-decoration'},
  ];

  final List<Map<String, String>> festivalEvents = [
    {'name': 'Baby Shower', 'image': 'assets/baby-shower.jpg', 'description': 'Baby shower for Boy décor','modelName': 'babyshower-boy-decoration'},
  ];

  final List<Map<String, String>> westEvent = [
    {'name': 'Garden Decor', 'image': 'assets/graden.jpg', 'description': 'western garden decoration' ,'modelName': 'western-decor'},
    {'name': 'Pink Decor', 'image': 'assets/pink-decor.jpg', 'description': 'Western Pink wedding decoration', 'modelName': 'pink-engagement-decoration'},
  ];

  List<Map<String, String>> filteredEvents = [];
  List<Map<String, String>> allEvents = [];

  final Color primaryColor = const Color(0xFF4A4E69);
  final Color secondaryColor = const Color(0xFFC9ADA7);

  @override
  void initState() {
    super.initState();
    allEvents = [...weddingEvents, ...birthdayEvents, ...corporateEvents, ...festivalEvents, ...westEvent];
    filteredEvents = List.from(allEvents);
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            userName = doc['name'] ?? "User";
          });
        } else {
          setState(() {
            userName = "User";
          });
        }
      } catch (e) {
        setState(() {
          userName = "User";
        });
      }
    }
  }

  void _filterEvents(String query) {
    setState(() {
      filteredEvents = allEvents.where((event) {
        final name = event['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Hi $userName",
          style: const TextStyle(
            color: Color(0xFF4A4E69),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xFF4A4E69)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search for event setup...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF4A4E69)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                  onChanged: _filterEvents,
                  cursorColor: primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // AR Banner
              Stack(
                children: [
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/ar_banner_bg.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black54,
                          BlendMode.darken,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visualize your venue in AR',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                              ),
                              child: const Text("Try Now"),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Categories
              const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final events = {
                      'Wedding': weddingEvents,
                      'Birthday': birthdayEvents,
                      'Corporate': corporateEvents,
                      'Festival': festivalEvents
                    };
                    return GestureDetector(
                      onTap: () {
                        final label = cat['label']!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventCategoryScreen(
                              title: '$label Events',
                              events: events[label] ?? [],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(cat['image']!),
                          ),
                          const SizedBox(height: 6),
                          Text(cat['label']!, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Color Detection Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EventThemeDetectorScreen()),
                  );
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.color_lens, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        "Color Detection",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Explore Events
              const Text("Explore Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredEvents.take(4).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/event_detail', arguments: event);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(event['image']!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['name']!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event['description'] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
