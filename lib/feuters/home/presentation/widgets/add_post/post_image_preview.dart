import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:video_player/video_player.dart';

class PostVideoPreview extends StatefulWidget {
  const PostVideoPreview({super.key});

  @override
  State<PostVideoPreview> createState() => _PostVideoPreviewState();
}

class _PostVideoPreviewState extends State<PostVideoPreview> {
  VideoPlayerController? _controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostStates>(
      builder: (context, state) {
        if (postCubit.postVideo == null) {
          if (_controller != null) {
            _controller!.dispose();
            _controller = null;
          }
          return GestureDetector(
            onTap: () => postCubit.pickPostVideo(),
            child: DashedBorder(
              strokeWidth: 1.5,
              color: ColorsManager.textSecondaryColor,
              radius: 20,
              dashLength: 8,
              gapLength: 4,
              child: Container(
                height: MediaQuery.of(context).size.height * .35,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorsManager.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            ColorsManager.primary,
                            ColorsManager.pinkGradient,
                            ColorsManager.orange,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appTranslation().get('upload_video'),
                      style: TextStyle(
                        color: ColorsManager.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Initialize controller if video is picked and controller is null
        if (_controller == null && postCubit.postVideo != null) {
          _controller = VideoPlayerController.file(postCubit.postVideo!)
            ..initialize()
                .then((_) {
                  if (mounted) setState(() {});
                })
                .catchError((error) {
                  debugPrint("Error initializing video: $error");
                  // Optionally handle error state
                });
        }

        return Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .35,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _controller != null && _controller!.value.isInitialized
                    ? VideoPlayer(_controller!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  postCubit.removePostVideo();
                  if (_controller != null) {
                    _controller!.dispose();
                    _controller = null;
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black54,
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

// ---- DashedBorder Custom Painter ----
class DashedBorder extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;

  const DashedBorder({
    super.key,
    required this.child,
    this.strokeWidth = 2,
    this.color = Colors.grey,
    this.radius = 12,
    this.dashLength = 8,
    this.gapLength = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        strokeWidth: strokeWidth,
        color: color,
        radius: radius,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;

  _DashedBorderPainter({
    required this.strokeWidth,
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = Path();

    double distance = 0.0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
