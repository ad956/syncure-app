import 'package:flutter/material.dart';
import 'error_boundary.dart';

class SafeWidget extends StatelessWidget {
  final Widget child;
  final String? fallbackMessage;

  const SafeWidget({
    super.key,
    required this.child,
    this.fallbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      fallbackMessage: fallbackMessage,
      child: child,
    );
  }
}

class SafeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BoxDecoration? decoration;

  const SafeContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return SafeWidget(
      fallbackMessage: 'Container error',
      child: Container(
        padding: padding,
        margin: margin,
        color: color,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

class SafeColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const SafeColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return SafeWidget(
      fallbackMessage: 'Column layout error',
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.map((child) => SafeWidget(child: child)).toList(),
      ),
    );
  }
}

class SafeRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const SafeRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return SafeWidget(
      fallbackMessage: 'Row layout error',
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.map((child) => SafeWidget(child: child)).toList(),
      ),
    );
  }
}