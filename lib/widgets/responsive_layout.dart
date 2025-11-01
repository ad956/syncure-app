import 'package:flutter/material.dart';
import 'mobile_layout.dart';
import 'back_button_handler.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      currentRoute: currentRoute,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1200) {
            return _buildDesktopLayout();
          } else if (constraints.maxWidth >= 768) {
            return _buildTabletLayout();
          } else {
            return MobileLayout(currentRoute: currentRoute, child: child);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            color: Colors.white,
            child: _buildSidebar(),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 240,
            color: Colors.white,
            child: _buildSidebar(),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: const Row(
            children: [
              Icon(Icons.local_hospital, color: Color(0xFF6366F1), size: 32),
              SizedBox(width: 12),
              Text(
                'Syncure',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildNavItem('Dashboard', Icons.dashboard, '/dashboard'),
              _buildNavItem('Appointments', Icons.calendar_today, '/appointments'),
              _buildNavItem('Health Records', Icons.favorite, '/health-records'),
              _buildNavItem('Lab Results', Icons.science, '/lab-results'),
              _buildNavItem('Payments', Icons.payment, '/payments'),
              _buildNavItem('Profile', Icons.person, '/profile'),
              _buildNavItem('Chat', Icons.chat, '/chat'),
              _buildNavItem('Doctors', Icons.medical_services, '/doctors'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(String title, IconData icon, String route) {
    final isActive = currentRoute == route;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedTileColor: const Color(0xFF6366F1).withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          // Navigation will be handled by go_router
        },
      ),
    );
  }
}