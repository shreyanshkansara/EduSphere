import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/video_model.dart';
import '../services/history_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/video_card.dart';
import 'login_screen.dart';
import 'video_screen.dart';

class HistoryScreen extends StatefulWidget {
  final void Function(Video)? onVideoTap;
  const HistoryScreen({super.key, this.onVideoTap});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // We use a Future to track the load state, and update it when the page comes into view
  Future<List<Video>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _historyFuture = HistoryService.getHistory(user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while Firebase initializes the state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final User? user = snapshot.data;

          if (user == null) {
            // Unauthenticated State
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 100,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sign in to view watch history',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Keep track of what you watch, save videos for later, and get better recommendations.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Sign In', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          }

          // Trigger refresh if we didn't have user initially but do now
          if (_historyFuture == null) {
            _refreshHistory();
            return const Center(child: CircularProgressIndicator());
          }

          // Authenticated State - Show Real History
          return RefreshIndicator(
            onRefresh: () async {
              _refreshHistory();
              if (_historyFuture != null) await _historyFuture;
            },
            child: FutureBuilder<List<Video>>(
              future: _historyFuture,
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (futureSnapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text('Failed to load history.'),
                          Text(
                            futureSnapshot.error.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!futureSnapshot.hasData || futureSnapshot.data!.isEmpty) {
                  return CustomScrollView(
                    slivers: [
                      const CustomAppBar(),
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.video_library, size: 64, color: Colors.white24),
                              SizedBox(height: 16),
                              Text('Your watch history is empty.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
  
                final videos = futureSnapshot.data!;
                return CustomScrollView(
                  slivers: [
                    const CustomAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Watch History',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await HistoryService.clearHistory(user.uid);
                                _refreshHistory();
                              },
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                              label: const Text('Clear', style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final video = videos[index];
                            return VideoCard(
                              video: video,
                              onTap: () async {
                                widget.onVideoTap?.call(video);
                              },
                            );
                          },
                          childCount: videos.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
