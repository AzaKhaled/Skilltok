import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'video_state.dart';

class VideoCubit extends Cubit<VideoStates> {
  VideoCubit() : super(VideoInitialState());

  // ignore: strict_top_level_inference
  static VideoCubit get(context) => BlocProvider.of(context);

  final List<VideoPlayerController> _activeVideos = [];

  void registerVideoController(VideoPlayerController controller) {
    _activeVideos.add(controller);
  }

  void unregisterVideoController(VideoPlayerController controller) {
    _activeVideos.remove(controller);
  }

  bool _userPaused = false;

  bool get userPaused => _userPaused;

  void togglePlayPause(VideoPlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
      _userPaused = true;
    } else {
      controller.play();
      _userPaused = false;
    }
  }

  void playOnly(VideoPlayerController activeController) {
    if (_userPaused) return;

    for (final controller in _activeVideos) {
      if (controller == activeController) {
        if (!controller.value.isPlaying) {
          controller
            ..setLooping(true)
            ..play();
        }
      } else {
        controller.pause();
      }
    }
  }

  void pauseAllVideos() {
    for (final controller in _activeVideos) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }
}
