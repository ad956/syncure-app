import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_theme.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, '/dashboard', context),
          _buildNavItem(Icons.qr_code_outlined, Icons.qr_code, '/qr', context),
          _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, '/appointments', context),
          _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, '/payments', context),
          _buildNavItem(Icons.medical_services_outlined, Icons.medical_services, '/medical-history', context),
          const Spacer(),
          _buildNavItem(Icons.settings_outlined, Icons.settings, '/profile', context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon, String route, BuildContext context) {
    final isActive = currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1F2937) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isActive ? filledIcon : outlinedIcon,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
            size: 24,
          ),
        ),
      ),
    );
  }
}