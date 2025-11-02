import 'package:flutter/material.dart';

class LoadingSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade300.withOpacity(_animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class LoadingCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const LoadingCard({
    super.key,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LoadingSkeleton(width: 40, height: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    LoadingSkeleton(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (height != null && height! > 100) ...[
            const SizedBox(height: 20),
            const Expanded(
              child: LoadingSkeleton(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
        ],
      ),
    );
  }
}