import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Material Design 3 Expressive Design Tokens for Quran HD
abstract final class AppShapes {
  /// 8dp - Badges, small chips, compact tags
  static const double small = 8;
  static const Radius radiusSmall = Radius.circular(small);
  static const BorderRadius borderSmall = BorderRadius.all(radiusSmall);
  static const RoundedRectangleBorder shapeSmall =
      RoundedRectangleBorder(borderRadius: borderSmall);

  /// 12dp - Inner containers, metric tiles, preview blocks
  static const double medium = 12;
  static const Radius radiusMedium = Radius.circular(medium);
  static const BorderRadius borderMedium = BorderRadius.all(radiusMedium);
  static const RoundedRectangleBorder shapeMedium =
      RoundedRectangleBorder(borderRadius: borderMedium);

  /// 16dp - Cards, group tiles, bottom sheets, dialogs
  static const double large = 16;
  static const Radius radiusLarge = Radius.circular(large);
  static const BorderRadius borderLarge = BorderRadius.all(radiusLarge);
  static const RoundedRectangleBorder shapeLarge =
      RoundedRectangleBorder(borderRadius: borderLarge);

  /// 28dp - Search bars, floating action bars, hero pills
  static const double extraLarge = 28;
  static const Radius radiusExtraLarge = Radius.circular(extraLarge);
  static const BorderRadius borderExtraLarge =
      BorderRadius.all(radiusExtraLarge);
  static const RoundedRectangleBorder shapeExtraLarge =
      RoundedRectangleBorder(borderRadius: borderExtraLarge);

  /// Full stadium shape
  static const StadiumBorder stadium = StadiumBorder();
}

/// Material Design 3 Spacing & Layout Tokens
abstract final class AppSpacing {
  /// 4dp - Micro spacing, badge padding
  static const double xs = 4;

  /// 8dp - Compact spacing, element gaps
  static const double sm = 8;

  /// 12dp - Intermediate spacing
  static const double mdSm = 12;

  /// 16dp - Standard container padding, card gutters
  static const double md = 16;

  /// 24dp - Section spacing, header margins
  static const double lg = 24;

  /// 32dp - Hero section gaps
  static const double xl = 32;

  /// Minimum accessible touch target (48dp per M3 & WCAG 2.1 AAA)
  static const double touchTarget = 48;
}

/// M3 Tablet containment token: max content width for comfortable readability
abstract final class AppLayout {
  static const double maxContentWidth = 840;
}

/// Adaptive container ensuring tablet-optimized readable width
class AdaptiveContent extends StatelessWidget {
  const AdaptiveContent({
    required this.child,
    super.key,
    this.maxWidth = AppLayout.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

/// M3 Expressive Spring Simulation & Transitions
class Md3SpringSimulation extends Simulation {
  Md3SpringSimulation({
    required double start,
    required double end,
    SpringDescription? spring,
  })  : _spring = spring ??
            const SpringDescription(mass: 1.0, stiffness: 220.0, damping: 14.0),
        _start = start,
        _end = end {
    _sim = SpringSimulation(_spring, _start, _end, 0.0);
  }

  final SpringDescription _spring;
  final double _start;
  final double _end;
  late final SpringSimulation _sim;

  @override
  double x(double time) => _sim.x(time);

  @override
  double dx(double time) => _sim.dx(time);

  @override
  bool isDone(double time) => _sim.isDone(time);
}

/// Expressive entry animation widget with spring physics and a11y support
class Md3SpringAppear extends StatefulWidget {
  const Md3SpringAppear({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.initialScale = 0.92,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double initialScale;

  @override
  State<Md3SpringAppear> createState() => _Md3SpringAppearState();
}

class _Md3SpringAppearState extends State<Md3SpringAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // Expressive overshoot spring-like curve
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect Reduced Motion accessibility setting
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
