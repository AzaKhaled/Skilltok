import 'package:flutter/material.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:skilltok/main.dart';

class PostVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const PostVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
  });

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer>
    with WidgetsBindingObserver, RouteAware {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        _initialized = true;

        // تسجيل الكنترولر في VideoCubit
        videoCubit.registerVideoController(_controller);

        if (widget.autoPlay) {
          _controller.play();
        }

        setState(() {});
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.autoPlay && !videoCubit.userPaused) {
        _controller.play();
      }
    }
  }

  @override
  void didPushNext() {
    if (_initialized && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void didPopNext() {
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    videoCubit.unregisterVideoController(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || !_controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );
    }

    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.6 && !videoCubit.userPaused) {
          videoCubit.playOnly(_controller);
        } else {
          _controller.pause();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          videoCubit.togglePlayPause(_controller); // شغل/وقف الفيديو
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (!_controller.value.isPlaying)
              Icon(
                Icons.play_arrow_rounded,
                size: 70,
                color: Colors.white.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    );
  }
}
