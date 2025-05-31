import 'package:flutter/material.dart';

class NoTransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  NoTransitionRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
}
