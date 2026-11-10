import 'dart:async';

import 'package:flutter/material.dart';

// Auto-scrolling ticker: continuously scrolls child to its end and back,
// pausing at each end, to reveal overflowing content (e.g. long text/lists).
class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration;
  final Duration backDuration;
  final Duration pauseDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 6000),
    this.backDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late final ScrollController scrollController;
  Timer? _pauseTimer;

  @override
  void initState() {
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleScroll(true));
    super.initState();
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: widget.direction,
      controller: scrollController,
      child: widget.child,
    );
  }

  void _scheduleScroll(bool forward) {
    if (!mounted ||
        !scrollController.hasClients ||
        scrollController.position.maxScrollExtent <= 0) {
      return;
    }
    _pauseTimer = Timer(widget.pauseDuration, () async {
      if (!mounted || !scrollController.hasClients) return;
      await scrollController.animateTo(
        forward ? scrollController.position.maxScrollExtent : 0,
        duration: forward ? widget.animationDuration : widget.backDuration,
        curve: forward ? Curves.ease : Curves.easeOut,
      );
      _scheduleScroll(!forward);
    });
  }
}
