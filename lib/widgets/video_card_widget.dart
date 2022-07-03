import 'package:flutter/material.dart';

import 'package:mock_streaming_platform/models/video_model.dart';
import 'package:mock_streaming_platform/screens/landing_screen.dart';

import 'package:video_player/video_player.dart';

class VideoCardWidget extends StatefulWidget {
  const VideoCardWidget({
    Key? key,
    required this.index,
    required this.topCard,
    required this.screenSize,
    required this.videos,
  }) : super(key: key);

  final int index;
  final int topCard;
  final Size? screenSize;
  final List<VideoModel> videos;

  @override
  State<VideoCardWidget> createState() => _VideoCardWidgetState();
}

class _VideoCardWidgetState extends State<VideoCardWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
      widget.videos[widget.index].videoUrl,
    );

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.topCard == widget.index)) {
      _controller.pause();
    }
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: Material(
          elevation: 8,
          child: Column(
            children: [
              SizedBox(
                height: widget.screenSize!.width * 9 / 16,
                width: widget.screenSize!.width,
                child: Stack(
                  children: [
                    (widget.index == widget.topCard && LandingScreen.toPlay)
                        ? FutureBuilder(
                            future: _initializeVideoPlayerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                _controller.play();
                                _controller.setVolume(
                                    LandingScreen.playbackMuted ? 0 : 1);
                                return AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(
                                    _controller,
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          )
                        : Image.network(
                            widget.videos[widget.index].coverPicture,
                            fit: BoxFit.cover,
                          ),
                    Center(
                      child: (widget.index == widget.topCard &&
                              LandingScreen.toPlay)
                          ? const SizedBox.shrink()
                          : Icon(
                              Icons.play_circle_outline,
                              color: Colors.white.withOpacity(0.75),
                              size: 96,
                            ),
                    ),
                    (widget.index == widget.topCard && LandingScreen.toPlay)
                        ? Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  if (LandingScreen.playbackMuted) {
                                    setState(() {
                                      LandingScreen.playbackMuted = false;
                                      _controller.setVolume(1);
                                    });
                                  } else {
                                    setState(() {
                                      LandingScreen.playbackMuted = true;
                                      _controller.setVolume(0);
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      (LandingScreen.playbackMuted)
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white.withOpacity(0.75),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    (widget.index == widget.topCard && LandingScreen.toPlay)
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ValueListenableBuilder(
                                valueListenable: _controller,
                                builder:
                                    (context, VideoPlayerValue value, child) {
                                  Duration remaining =
                                      value.duration - value.position;
                                  int hours = remaining.inHours;
                                  int minutes = remaining.inMinutes -
                                      hours * Duration.minutesPerHour;
                                  int seconds = remaining.inSeconds -
                                      hours * Duration.secondsPerHour -
                                      minutes * Duration.secondsPerMinute;
                                  String remTimeString;
                                  if (hours > 0) {
                                    remTimeString =
                                        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                  } else {
                                    remTimeString =
                                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                        vertical: 2.0,
                                      ),
                                      child: Text(
                                        remTimeString,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.75),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.videos[widget.index].title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
