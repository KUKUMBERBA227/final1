import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MusicState(),
      builder: (context, child) => const MusicApp(),
    ),
  );
}

class Track {
  final String title;
  final String artist;
  final String duration;
  final String imageUrl;

  const Track({
    required this.title,
    required this.artist,
    required this.duration,
    required this.imageUrl,
  });
}

class MusicState extends ChangeNotifier {
  Track? _currentlyPlaying;
  bool _isPlaying = false;
  int _currentIndex = 0;

  Track? get currentlyPlaying => _currentlyPlaying;
  bool get isPlaying => _isPlaying;
  int get currentIndex => _currentIndex;

  void play(Track track) {
    _currentlyPlaying = track;
    _isPlaying = true;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFC4F4F),
        ),
      ),
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<MusicState>(context);
    final pages = [
      const HomeScreen(),
      const FavoriteScreen(),
      const SearchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: state.currentIndex,
        onTap: (index) => state.setIndex(index),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFFFC4F4F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Track> _tracks = [
    Track(title: 'Neon Nights', artist: 'Synthwave Collective', duration: '3:45', imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg'),
    Track(title: 'Ocean Breeze', artist: 'Deep Soul', duration: '4:12', imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400'),
    Track(title: 'Mountain Echo', artist: 'Alpine Drift', duration: '2:55', imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF222222),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hello, Music', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 200, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tracks.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_tracks[index].imageUrl, width: 160, height: 200, fit: BoxFit.cover)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _tracks.length,
            itemBuilder: (context, index) {
              final track = _tracks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(track: track))),
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(track.imageUrl, width: 45, height: 45, fit: BoxFit.cover)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(track.title, style: const TextStyle(fontWeight: FontWeight.w600)), Text(track.artist, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
                      Text(track.duration, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PlayerScreen extends StatelessWidget {
  final Track track;
  const PlayerScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicState>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.black))),
          body: Column(
            children: [
              const SizedBox(height: 40),
              ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.network(track.imageUrl, width: 300, height: 300, fit: BoxFit.cover)),
              const SizedBox(height: 40),
              Text(track.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                height: 90,
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.refresh, color: Colors.white)),
                    const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                    GestureDetector(
                      onTap: () => state.togglePlay(),
                      child: CircleAvatar(radius: 30, backgroundColor: const Color(0xFFFC4F4F), child: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30)),
                    ),
                    const Icon(Icons.skip_next, color: Colors.white, size: 30),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: Colors.white)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class FavoriteScreen extends StatelessWidget { const FavoriteScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Favorites Interface'))); }
class SearchScreen extends StatelessWidget { const SearchScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Search Interface'))); }
class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile Interface'))); }
