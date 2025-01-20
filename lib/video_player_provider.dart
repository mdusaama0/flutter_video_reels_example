import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_reels_example/mock_data.dart';
import 'package:flutter_video_reels_example/video_model.dart';

class VideoPlayerProvider extends ChangeNotifier {
  var currentReelIndex = 0;
  var loading = true;
  BetterPlayerController? reelsController =
      BetterPlayerController(const BetterPlayerConfiguration());
  final cacheController =
      BetterPlayerController(const BetterPlayerConfiguration());
  List<VideoModel> videosList = [];

  void fetchReelsFromAPI() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      videosList = MockData.videosList;
      if (videosList.isNotEmpty) {
        loading = false;
        await cacheImage(videosList.first.thumbnailUrl);
        if (videosList.length > 1) {
          await cacheImage(videosList[1].thumbnailUrl);
          cacheController.preCache(initDataSource(videosList[1].videoUrl));
        }
        createReelsController(videosList.first.videoUrl);
      }
    } catch (e) {
      rethrow;
    }
  }

  void createReelsController(String url) {
    disposeController();

    BetterPlayerDataSource betterPlayerDataSource = initDataSource(url);
    reelsController = BetterPlayerController(
      BetterPlayerConfiguration(
        placeholder: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: videosList[currentReelIndex].thumbnailUrl,
          placeholder: (context, url) => const SizedBox(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        autoDispose: false,
        autoPlay: false,
        looping: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black26,
          showControls: false,
          enableFullscreen: false,
          enableProgressBar: false,
          loadingWidget: SizedBox(),
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    reelsController?.addEventsListener((event) {
      if (reelsController!.isVideoInitialized()! &&
          !reelsController!.isPlaying()!) {
        notifyListeners();
      }
    });
  }

  playVideo() => reelsController?.play();

  BetterPlayerDataSource initDataSource(String url) {
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 3000,
        maxBufferMs: 10000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 3 * 1024 * 1024, //It will cache 3MB of the video
        maxCacheSize: 500 *
            1024 *
            1024, //Max cache will be 500MB and when it reaches 500MB it will release the initial cached videos
        maxCacheFileSize: 3 * 1024 * 1024, //Max size for cache
        key: Platform.isIOS ? url : null,
      ),
    );
  }

  onPageChange(int index) async {
    try {
      //The variable currentReelIndex is updated to reflect the index of the current video reel being viewed.
      currentReelIndex = index;

      //A new video controller is created and initialized for the video URL corresponding to the current index.
      createReelsController(videosList[currentReelIndex].videoUrl);

      //If the current reel is not the last one, the function pre-caches the next video's data and its thumbnail.
      if (currentReelIndex < videosList.length - 1) {
        cacheController.preCache(
            initDataSource(videosList[currentReelIndex + 1].videoUrl));
        cacheImage(videosList[currentReelIndex + 1].thumbnailUrl);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cacheImage(String url) async {
    try {
      final imageProvider = CachedNetworkImageProvider(url);

      final Completer<void> completer = Completer();
      final ImageStreamListener listener =
          ImageStreamListener((ImageInfo image, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }, onError: (dynamic exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(exception);
        }
      });

      imageProvider.resolve(const ImageConfiguration()).addListener(listener);
      await completer.future;
    } catch (e) {
      rethrow;
    }
  }

  disposeController() {
    if (reelsController != null) {
      reelsController?.removeEventsListener((event) {});
      reelsController?.dispose(forceDispose: true);
      reelsController = null;
    }
  }
}
