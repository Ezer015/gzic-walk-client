import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'collection_page.dart';
import '../service.dart';
import '../component.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  ({
    String copywriting,
    int imageID,
    int recordID,
    int sightID,
    String sightName,
  })? _sharingCardData;

  @override
  void initState() {
    super.initState();
    _fetchRandomRecord();
  }

  Future<void> _fetchRandomRecord() async {
    final data = await RemoteApi.getRandomRecord();
    setState(() => _sharingCardData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/images/background.jpg",
                fit: BoxFit.cover,
              ),
            ),
            // Blur effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SharingCard(
                    key: ValueKey(_sharingCardData?.recordID),
                    id: _sharingCardData?.recordID,
                    imageID: _sharingCardData?.imageID,
                    name: _sharingCardData?.sightName,
                    description: _sharingCardData?.copywriting,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(0),
                        elevation: 8,
                      ),
                      onPressed: _fetchRandomRecord,
                      child: const Center(
                        child: Icon(
                          Icons.refresh,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox.shrink(),
        const CollectionPage(),
      ][_selectedIndex],
      floatingActionButton: Container(
        width: 85.0, // Adjust the width of the container
        height: 85.0, // Adjust the height of the container
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 10,
          ), // White border
        ),
        child: FloatingActionButton(
          onPressed: () async {
            if (context.mounted) {
              final navigator = Navigator.of(context);
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                final imageID = await RemoteApi.uploadImage(
                    imageFile: File(pickedFile.path));
                if (imageID != null) {
                  navigator.pushNamed('/result/$imageID');
                }
              }
            }
          },
          shape: const CircleBorder(), // Ensure the FAB is round
          child: const Icon(
            Icons.camera_enhance,
            size: 35.0,
          ), // Adjust the icon size if needed
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.85),
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Collection',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
