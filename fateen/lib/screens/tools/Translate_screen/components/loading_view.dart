// components/loading_view.dart

import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final double progressValue;
  final String message;

  const LoadingView({
    Key? key,
    required this.progressValue,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progressValue,
                strokeWidth: 6,
                backgroundColor: const Color(0xFFF5F3FF),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
              ),
              Center(
                child: Text(
                  "${(progressValue * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4338CA),
                    fontFamily: 'SYMBIOAR+LT',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF221291),
            fontFamily: 'SYMBIOAR+LT',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: const Color(0xFFF5F3FF),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
          borderRadius: BorderRadius.circular(10),
          minHeight: 6,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
