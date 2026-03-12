import 'package:flutter/material.dart';

import '../models/video_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/video_card.dart';
import 'video_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Video)? onVideoTap;
  const HomeScreen({super.key, this.onVideoTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Video> _videos = [];
  
  String? _nextPageToken;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchInitialVideos();
    
    // Listen to scroll events to trigger infinite scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchMoreVideos();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialVideos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiService.fetchVideos();
      setState(() {
        _videos.addAll(response.videos);
        _nextPageToken = response.nextPageToken;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreVideos() async {
    // Prevent multiple simultaneous fetches or fetching if there's no next page
    if (_isLoading || _nextPageToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.fetchVideos(pageToken: _nextPageToken);
      setState(() {
        _videos.addAll(response.videos);
        _nextPageToken = response.nextPageToken;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Optionally show a silent snackbar error here instead of breaking the feed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError && _videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'API Error: Did you add your API Key in api_service.dart?',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchInitialVideos,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_videos.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty && !_isLoading) {
      return const Center(child: Text('No videos found.'));
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth >= 600;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        const CustomAppBar(),
        SliverPadding(
          padding: isWideScreen ? const EdgeInsets.all(16.0) : EdgeInsets.zero,
          sliver: isWideScreen
              ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 1200 ? 4 : (screenWidth > 900 ? 3 : 2),
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.9, // Adjusted for VideoCard layout (thumbnail + text)
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _videos.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final video = _videos[index];
                      return VideoCard(
                        video: video,
                        onTap: () {
                          widget.onVideoTap?.call(video);
                        },
                      );
                    },
                    childCount: _isLoading ? _videos.length + 1 : _videos.length,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _videos.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final video = _videos[index];
                      return VideoCard(
                        video: video,
                        onTap: () {
                          widget.onVideoTap?.call(video);
                        },
                      );
                    },
                    childCount: _isLoading ? _videos.length + 1 : _videos.length,
                  ),
                ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 60.0)),
      ],
    );
  }
}
