import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  late final Animation<double> _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _rise = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(_fade);

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Subtle decorative rings
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 40)),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -100,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 46)),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _rise,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))],
                      ),
                      child: const Center(
                        child: Text(
                          'W',
                          style: TextStyle(fontFamily: 'Sora', fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(fontFamily: 'Sora', fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.appSubtitle.toUpperCase(),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, letterSpacing: 2.4, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 46,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${AppConstants.companyName} · ${AppConstants.version}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}