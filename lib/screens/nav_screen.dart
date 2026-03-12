import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'chatbot_screen.dart';
import 'video_screen.dart';
import '../models/video_model.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;
  Video? _selectedVideo;

  void _handleVideoTap(Video video) {
    setState(() {
      _selectedVideo = video;
    });
  }

  void _handleTabTap(int i) {
    setState(() {
      _selectedIndex = i;
      _selectedVideo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recreate screens each build so they get the latest callbacks
    final screensList = [
      HomeScreen(onVideoTap: _handleVideoTap),
      HistoryScreen(onVideoTap: _handleVideoTap),
      const ChatbotScreen(),
    ];

    Widget buildBody() {
      if (_selectedVideo != null) {
        return VideoScreen(
          key: ValueKey(_selectedVideo!.id),
          video: _selectedVideo!,
          onVideoTap: _handleVideoTap,
        );
      }
      return Stack(
        children: screensList
            .asMap()
            .map((i, screen) => MapEntry(
                i,
                Offstage(
                  offstage: _selectedIndex != i,
                  child: screen,
                )))
            .values
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _handleTabTap,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  selectedLabelTextStyle: const TextStyle(color: Colors.white),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
                  backgroundColor: const Color(0xFF0F0F0F),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.smart_toy_outlined),
                      selectedIcon: Icon(Icons.smart_toy),
                      label: Text('AI Chat'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.white24),
                Expanded(
                  child: buildBody(),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: buildBody(),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _handleTabTap,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy_outlined),
                activeIcon: Icon(Icons.smart_toy),
                label: 'AI Chat',
              ),
            ],
          ),
        );
      },
    );
  }
}
