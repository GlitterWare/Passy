import 'dart:async';

import 'package:chewie_media_kit/chewie.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:flutter/material.dart';

class VideoProgressBar extends StatefulWidget {
  VideoProgressBar(
    this.controller, {
    ChewieProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    super.key,
    required this.barHeight,
    required this.handleHeight,
    required this.drawShadow,
  }) : colors = colors ?? ChewieProgressColors();

  final VideoController controller;
  final ChewieProgressColors colors;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;

  final double barHeight;
  final double handleHeight;
  final bool drawShadow;

  @override
  // ignore: library_private_types_in_public_api
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  void listener() {
    if (!mounted) return;
    setState(() {});
  }

  bool _controllerWasPlaying = false;

  Offset? _latestDraggableOffset;

  StreamSubscription<Duration>? _subscription;

  VideoController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _subscription = controller.player.stream.position.listen((_) => listener());
  }

  @override
  void deactivate() {
    _subscription?.cancel;
    super.deactivate();
  }

  void _seekToRelativePosition(Offset globalPosition) {
    controller.player.seek(context.calcRelativePosition(
      controller.player.state.duration,
      globalPosition,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: StaticProgressBar(
        value: controller,
        colors: widget.colors,
        barHeight: widget.barHeight,
        handleHeight: widget.handleHeight,
        drawShadow: widget.drawShadow,
        latestDraggableOffset: _latestDraggableOffset,
      ),
    );

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        _controllerWasPlaying = controller.player.state.playing;
        if (_controllerWasPlaying) {
          controller.player.pause();
        }

        widget.onDragStart?.call();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _latestDraggableOffset = details.globalPosition;
        listener();

        widget.onDragUpdate?.call();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.player.play();
        }

        if (_latestDraggableOffset != null) {
          _seekToRelativePosition(_latestDraggableOffset!);
          _latestDraggableOffset = null;
        }

        widget.onDragEnd?.call();
      },
      onTapDown: (TapDownDetails details) {
        _seekToRelativePosition(details.globalPosition);
      },
      child: child,
    );
  }
}

class StaticProgressBar extends StatelessWidget {
  const StaticProgressBar({
    super.key,
    required this.value,
    required this.colors,
    required this.barHeight,
    required this.handleHeight,
    required this.drawShadow,
    this.latestDraggableOffset,
  });

  final Offset? latestDraggableOffset;
  final VideoController value;
  final ChewieProgressColors colors;

  final double barHeight;
  final double handleHeight;
  final bool drawShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: CustomPaint(
        painter: _ProgressBarPainter(
          value: value,
          draggableValue: latestDraggableOffset != null
              ? context.calcRelativePosition(
                  value.player.state.duration,
                  latestDraggableOffset!,
                )
              : null,
          colors: colors,
          barHeight: barHeight,
          handleHeight: handleHeight,
          drawShadow: drawShadow,
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({
    required this.value,
    required this.colors,
    required this.barHeight,
    required this.handleHeight,
    required this.drawShadow,
    required this.draggableValue,
  });

  VideoController value;
  ChewieProgressColors colors;

  final double barHeight;
  final double handleHeight;
  final bool drawShadow;

  /// The value of the draggable progress bar.
  /// If null, the progress bar is not being dragged.
  final Duration? draggableValue;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseOffset = size.height / 2 - barHeight / 2;
    if (baseOffset.isNaN) return;
    if (barHeight.isNaN) return;
    if (size.width.isNaN) return;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    final double playedPartPercent = (draggableValue != null
            ? draggableValue!.inMilliseconds
            : value.player.state.position.inMilliseconds) /
        value.player.state.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    if (playedPart.isNaN) return;
    /*
    for (final DurationRange range in value.player.state.duration) {
      final double start =
          range.startFraction(value.player.state.duration) * size.width;
      final double end =
          range.endFraction(value.player.state.duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, baseOffset),
            Offset(end, baseOffset + barHeight),
          ),
          const Radius.circular(4.0),
        ),
        colors.bufferedPaint,
      );
    }
    */
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );

    if (drawShadow) {
      final Path shadowPath = Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(playedPart, baseOffset + barHeight / 2),
            radius: handleHeight,
          ),
        );

      canvas.drawShadow(shadowPath, Colors.black, 0.2, false);
    }

    canvas.drawCircle(
      Offset(playedPart, baseOffset + barHeight / 2),
      handleHeight,
      colors.handlePaint,
    );
  }
}

extension RelativePositionExtensions on BuildContext {
  Duration calcRelativePosition(
    Duration videoDuration,
    Offset globalPosition,
  ) {
    final box = findRenderObject()! as RenderBox;
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = (tapPos.dx / box.size.width).clamp(0, 1);
    final Duration position = videoDuration * relative;
    return position;
  }
}
