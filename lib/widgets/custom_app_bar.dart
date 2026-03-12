import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/video_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../screens/video_screen.dart';
import '../screens/login_screen.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF0F0F0F),
      leadingWidth: 150.0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Row(
          children: [
            const Icon(Icons.school, color: Colors.blueAccent, size: 28),
            const SizedBox(width: 8),
            const Text(
              'EduSphere',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: VideoSearchDelegate(),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 8.0),
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final User? user = snapshot.data;
              
              if (user != null) {
                // User is signed in
                return GestureDetector(
                  onTap: () {
                    _showUserMenu(context, user);
                  },
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      user.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 14, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                );
              } else {
                // User is signed out
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showUserMenu(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  user.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 28, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.email ?? 'Unknown User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pop(context); // Close the bottom sheet
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Padding for the bottom
            ],
          ),
        );
      },
    );
  }
}

class VideoSearchDelegate extends SearchDelegate<String?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0F0F),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    return FutureBuilder<List<Video>>(
      future: ApiService.fetchVideos(query: query).then((res) => res.videos),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        final videos = snapshot.data!;
        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              leading: Image.network(
                video.thumbnailUrl,
                width: 120,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 120, height: 90, color: Colors.grey),
              ),
              title: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('${video.channelTitle} • ${video.viewCount} views'),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideoScreen(video: video)),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Search for educational videos'));
  }
}
