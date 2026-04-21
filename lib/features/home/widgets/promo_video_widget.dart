import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_theme.dart';

class PromoVideoWidget extends StatefulWidget {
  final double height;
  const PromoVideoWidget({super.key, this.height = 380});

  @override
  State<PromoVideoWidget> createState() => _PromoVideoWidgetState();
}

class _PromoVideoWidgetState extends State<PromoVideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/promo_video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.setVolume(0); // Muted for autoplay
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: AppColors.border), // Removed to eliminate potential lines
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _isInitialized
            ? Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.15, // Scale up slightly to hide the built-in logo on the right side of the video
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                  // Centered Branding Overlay
                  // Semi-transparent Overlay for Text Clarity
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),

                  // Centered Branding Logo (slightly below center)
                  Align(
                    alignment: const Alignment(0, 0.35),
                    child: Image.asset(
                      'assets/images/masoor_branch.png',
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )


            : const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
      ),
    );
  }
}
