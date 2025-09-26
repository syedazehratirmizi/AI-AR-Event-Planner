import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _pickedImage;
  String userName = "Loading...";
  String userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            userName = doc['name'] ?? "User";
            userEmail = doc['email'] ?? user.email ?? "";
          });
        } else {
          setState(() {
            userName = user.displayName ?? "User";
            userEmail = user.email ?? "";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          userName = "User";
          userEmail = user.email ?? "";
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Clear SharedPreferences login data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('loginExpiry');

    // Navigate back to Explore (then user can go to Login)
    Navigator.pushNamedAndRemoveUntil(context, '/explore', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gradient_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Profile Picture
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : const AssetImage('assets/profile.png')
                      as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(userName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(userEmail,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 30),

                // White Card Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading:
                        const Icon(Icons.favorite, color: Colors.black),
                        title: const Text("Favorite Events",
                            style: TextStyle(color: Colors.black)),
                        onTap: () {
                          Navigator.pushNamed(context, '/favorites');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading:
                        const Icon(Icons.logout, color: Colors.black),
                        title: const Text("Logout",
                            style: TextStyle(color: Colors.black)),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
