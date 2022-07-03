import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mock_streaming_platform/constants/mock_data.dart';
import 'package:mock_streaming_platform/models/video_model.dart';
import 'package:mock_streaming_platform/widgets/video_card_widget.dart';

import 'package:visibility_detector/visibility_detector.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  static bool toPlay = false;
  static bool playbackMuted = true;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isLoading = false;
  Size? screenSize;
  Set<int> currentlyVisible = {};
  int topCard = 0;

  List<VideoModel> videos = [];

  @override
  void initState() {
    super.initState();
    initSub();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initSub() async {
    setState(() {
      _isLoading = true;
    });

    for (Map<String, Object> o in MockData.streamData) {
      videos.add(VideoModel.fromMap(o));
    }

    setState(() {
      _isLoading = false;
    });

    await Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        LandingScreen.toPlay = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 211, 211, 211),
      appBar: AppBar(
        title: const Text('Mock Stream App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videos.isEmpty
              ? const Center(
                  child: Text('No videos found.'),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      Future.delayed(
                        const Duration(seconds: 1),
                        () {
                          setState(() {
                            LandingScreen.toPlay = true;
                          });
                        },
                      );
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return VisibilityDetector(
                        key: Key('$index'),
                        onVisibilityChanged: (VisibilityInfo info) {
                          if (info.visibleFraction == 1) {
                            setState(() {
                              currentlyVisible.add(index);
                            });
                          } else {
                            if (index == topCard) {
                              setState(() {
                                LandingScreen.toPlay = false;
                              });
                            }
                            setState(() {
                              currentlyVisible.remove(index);
                            });
                          }
                          if (!currentlyVisible.contains(topCard)) {
                            setState(() {
                              topCard = currentlyVisible.reduce(min);
                            });
                          }
                        },
                        child: VideoCardWidget(
                          topCard: topCard,
                          screenSize: screenSize,
                          videos: videos,
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
