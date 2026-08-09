import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../errors/failures.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

// ------------------------------------------------------------- shimmer

class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});
  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            colors: const [Color(0xFFE8ECF3), Color(0xFFF7F9FC), Color(0xFFE8ECF3)],
            stops: [math.max(0, v - 0.4), v, math.min(1, v + 0.4)],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.width, required this.height, this.radius = 8});
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// Generic card-shaped skeleton used across data screens.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.blocks = 3});
  final int blocks;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(blocks, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    SkeletonLine(width: 40, height: 40, radius: 12),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(width: 140, height: 13),
                          SizedBox(height: 8),
                          SkeletonLine(width: 90, height: 11),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const SkeletonLine(height: 12),
                const SizedBox(height: 8),
                SkeletonLine(width: MediaQuery.sizeOf(context).width * 0.5, height: 12),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ------------------------------------------------------- empty & error

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(color: AppColors.grayBg, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: AppColors.gray),
          ),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: 220,
              child: PrimaryButton(label: actionLabel!, onPressed: onAction, height: 46),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, this.error, this.onRetry, this.compact = false});
  final Object? error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offline = error is OfflineFailure;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 24 : 44, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(color: AppColors.dangerBg, shape: BoxShape.circle),
            child: Icon(offline ? Icons.wifi_off_rounded : Icons.error_outline, size: 30, color: AppColors.danger),
          ),
          const SizedBox(height: 14),
          Text(
            offline ? "You're offline" : 'Something went wrong',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            offline
                ? 'Reconnect to load the latest information.'
                : 'We could not load this information. Please try again.',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: SecondaryButton(label: 'Try Again', icon: Icons.refresh, onPressed: onRetry),
            ),
          ],
        ],
      ),
    );
  }
}

