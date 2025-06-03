import 'package:flutter/widgets.dart';

class UserDetailsScrollController {
  final ScrollController scrollController = ScrollController();

  // Expose title opacity as a ValueNotifier
  final ValueNotifier<double> titleOpacity = ValueNotifier(0.0);

  static const double _opacityThreshold = 150.0;

  UserDetailsScrollController() {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = scrollController.offset;
    double newOpacity = (offset / _opacityThreshold).clamp(0.0, 1.0);

    if (titleOpacity.value != newOpacity) {
      titleOpacity.value = newOpacity;
    }
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    titleOpacity.dispose();
  }
}
