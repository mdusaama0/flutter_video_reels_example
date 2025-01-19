import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_reels_example/mock_data.dart';
import 'package:flutter_video_reels_example/video_player_provider.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoReelsScreen extends StatelessWidget {
  const VideoReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<VideoPlayerProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return PageView.builder(
            physics: const CustomPageViewScrollPhysics(),
            itemCount: provider.videosList.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              provider.onPageChange(index);
            },
            itemBuilder: (context, index) {
              return index != provider.currentReelIndex
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 9 / 16,
                          child: CachedNetworkImage(
                            height: 9 / 16,
                            fit: BoxFit.cover,
                            imageUrl: MockData
                                .videosList[provider.currentReelIndex]
                                .thumbnailUrl,
                            placeholder: (context, url) => const SizedBox(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ],
                    )
                  : provider.reelsController?.videoPlayerController != null &&
                          provider.reelsController!.isVideoInitialized()!
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Stack(
                                children: [
                                  VisibilityDetector(
                                    key: Key(index.toString()),
                                    onVisibilityChanged: (info) {
                                      if (info.visibleFraction == 1.0) {
                                        provider.playVideo();
                                      }
                                    },
                                    child: BetterPlayer(
                                      controller: provider.reelsController!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 9 / 16,
                              child: CachedNetworkImage(
                                height: 600,
                                fit: BoxFit.cover,
                                imageUrl: MockData
                                    .videosList[provider.currentReelIndex]
                                    .thumbnailUrl,
                                placeholder: (context, url) => const SizedBox(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ],
                        );
            },
          );
        },
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 120,
        stiffness: 120,
        damping: 1,
      );
}
