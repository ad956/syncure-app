import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../themes/app_theme.dart';

class CustomScreenLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final IconData? icon;
  final Color? iconColor;

  const CustomScreenLayout({
    super.key,
    required this.child,
    required this.title,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF6366F1)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? const Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final items = [
      {'icon': Iconsax.home_1, 'activeIcon': Iconsax.home_15, 'label': 'Home', 'route': '/dashboard'},
      {'icon': Iconsax.scan, 'activeIcon': Iconsax.scan5, 'label': 'QR', 'route': '/qr'},
      {'icon': Iconsax.calendar, 'activeIcon': Iconsax.calendar5, 'label': 'Appts', 'route': '/appointments'},
      {'icon': Iconsax.wallet, 'activeIcon': Iconsax.wallet5, 'label': 'Payments', 'route': '/payments'},
      {'icon': Iconsax.health, 'activeIcon': Iconsax.health5, 'label': 'History', 'route': '/medical-history'},
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFF31260),
      unselectedItemColor: AppTheme.textSecondary,
      currentIndex: 0, // Always show home as selected for secondary screens
      onTap: (index) => context.go(items[index]['route'] as String),
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          activeIcon: Icon(item['activeIcon'] as IconData),
          label: item['label'] as String,
        );
      }).toList(),
    );
  }
}