import 'package:flutter/material.dart';
import 'package:flutter_video_reels_example/video_player_provider.dart';
import 'package:flutter_video_reels_example/video_reels_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => VideoPlayerProvider()..fetchReelsFromAPI()),
      ],
      child: MaterialApp(
        title: 'Flutter Video Reels Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const VideoReelsScreen(),
      ),
    );
  }
}
