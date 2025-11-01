import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'common_widgets.dart';

class ScreenTemplate extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget child;
  final List<Widget>? actions;

  const ScreenTemplate({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentRoute: currentRoute,
      child: ResponsiveBuilder(
        mobile: _buildMobileView(),
        tablet: _buildTabletView(),
        desktop: _buildDesktopView(),
      ),
    );
  }

  Widget _buildMobileView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: actions,
      ),
      body: ResponsiveWidget(child: child),
    );
  }

  Widget _buildTabletView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          Expanded(
            child: ResponsiveWidget(child: child),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView() {
    return _buildTabletView();
  }
}