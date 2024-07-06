import 'dart:async';
import 'dart:math' as math;

import 'package:chewie_media_kit/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/widgets/animated_play_pause.dart';

import 'progress_bar.dart';

class PassyAudioProgressBar extends StatefulWidget {
  final ChewieProgressColors? _colors;
  final Color iconColor;
  final VideoController controller;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;

  const PassyAudioProgressBar({
    super.key,
    required this.controller,
    required this.iconColor,
    ChewieProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
  }) : _colors = colors;

  @override
  State<StatefulWidget> createState() => _PassyAudioProgressBar();
}

class _PassyAudioProgressBar extends State<PassyAudioProgressBar> {
  late ChewieProgressColors colors;
  StreamSubscription<Duration>? _subscription;
  double selectedSpeed = 1.0;

  @override
  initState() {
    super.initState();
    colors = widget._colors ?? ChewieProgressColors();
    _subscription =
        widget.controller.player.stream.position.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  void _playPause() {
    final isFinished = widget.controller.player.state.completed;

    setState(() {
      if (widget.controller.player.state.playing) {
        widget.controller.player.pause();
      } else {
        if (isFinished) {
          widget.controller.player.seek(Duration.zero);
        }
        widget.controller.player.play();
      }
    });
  }

  Future<void> _skipBack() async {
    final beginning = Duration.zero.inMilliseconds;
    final skip =
        (widget.controller.player.state.position - const Duration(seconds: 15))
            .inMilliseconds;
    await widget.controller.player
        .seek(Duration(milliseconds: math.max(skip, beginning)));
    // Restoring the video speed to selected speed
    // A delay of 1 second is added to ensure a smooth transition of speed after reversing the video as reversing is an asynchronous function
    Future.delayed(const Duration(milliseconds: 1000), () {
      widget.controller.player.setRate(selectedSpeed);
    });
  }

  Future<void> _skipForward() async {
    final end = widget.controller.player.state.duration.inMilliseconds;
    final skip =
        (widget.controller.player.state.position + const Duration(seconds: 15))
            .inMilliseconds;
    await widget.controller.player
        .seek(Duration(milliseconds: math.min(skip, end)));
    // Restoring the video speed to selected speed
    // A delay of 1 second is added to ensure a smooth transition of speed after forwarding the video as forwaring is an asynchronous function
    Future.delayed(const Duration(milliseconds: 1000), () {
      widget.controller.player.setRate(selectedSpeed);
    });
  }

  GestureDetector _buildPlayPause(
    VideoController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: AnimatedPlayPause(
            color: iconColor,
            playing: controller.player.state.playing,
            size: 36.0),
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipBack,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          CupertinoIcons.gobackward_15,
          color: iconColor,
          size: 36.0,
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipForward,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          CupertinoIcons.goforward_15,
          color: iconColor,
          size: 36.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSkipBack(widget.iconColor, barHeight),
            _buildPlayPause(widget.controller, widget.iconColor, barHeight),
            _buildSkipForward(widget.iconColor, barHeight)
          ],
        ),
        SizedBox(
            height: 20,
            child: VideoProgressBar(
              widget.controller,
              barHeight: 10,
              handleHeight: 10,
              drawShadow: true,
              colors: colors,
              onDragEnd: widget.onDragEnd,
              onDragStart: widget.onDragStart,
              onDragUpdate: widget.onDragUpdate,
            )),
      ],
    );
  }
}
