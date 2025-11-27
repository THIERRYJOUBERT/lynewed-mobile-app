/// Animated marker widget with fade and scale effects
/// 
/// Provides smooth animations for marker appearance and selection.
/// Optimized for performance with minimal rebuilds.
library;

import 'package:flutter/material.dart';

/// Configuration for marker animations
class MarkerAnimationConfig {
  const MarkerAnimationConfig({
    this.fadeInDuration = const Duration(milliseconds: 200),
    this.fadeOutDuration = const Duration(milliseconds: 150),
    this.scaleDuration = const Duration(milliseconds: 100),
    this.selectedScale = 1.2,
    this.bounceDuration = const Duration(milliseconds: 150),
  });

  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Duration scaleDuration;
  final double selectedScale;
  final Duration bounceDuration;
}

/// Animated marker container
class AnimatedMarker extends StatefulWidget {
  const AnimatedMarker({
    super.key,
    required this.child,
    required this.isVisible,
    required this.isSelected,
    this.config = const MarkerAnimationConfig(),
    this.onAnimationComplete,
  });

  final Widget child;
  final bool isVisible;
  final bool isSelected;
  final MarkerAnimationConfig config;
  final VoidCallback? onAnimationComplete;

  @override
  State<AnimatedMarker> createState() => _AnimatedMarkerState();
}

class _AnimatedMarkerState extends State<AnimatedMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.fadeInDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: widget.isSelected ? widget.config.selectedScale : 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Start animation if visible
    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedMarker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    if (widget.isSelected != oldWidget.isSelected) {
      _scaleAnimation = Tween<double>(
        begin: _scaleAnimation.value,
        end: widget.isSelected ? widget.config.selectedScale : 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Marker appearance animation controller
class MarkerAnimationController {
  MarkerAnimationController({
    MarkerAnimationConfig? config,
  }) : _config = config ?? const MarkerAnimationConfig();

  final MarkerAnimationConfig _config;
  final Map<String, bool> _animatedMarkers = {};

  /// Check if marker should be animated
  bool shouldAnimate(String markerId) {
    return !_animatedMarkers.containsKey(markerId);
  }

  /// Mark marker as animated
  void markAsAnimated(String markerId) {
    _animatedMarkers[markerId] = true;
  }

  /// Reset animation cache
  void reset() {
    _animatedMarkers.clear();
  }

  /// Get animation duration for marker type
  Duration getAnimationDuration(bool isAppearing) {
    return isAppearing ? _config.fadeInDuration : _config.fadeOutDuration;
  }
}
