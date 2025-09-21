import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_theme.dart';
import '../data/mock_data.dart';
import '../services/novu_service.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const MobileLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            child: Image.asset(
              'assets/icons/patient.png',
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Syncure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32325D),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            NovuService.showNotifications(context);
          },
          icon: const Icon(Icons.notifications_outlined, size: 24),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF6B7280),
            backgroundColor: Colors.transparent,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF31260), width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(MockData.userProfile['avatar']),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/icons/patient.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Syncure',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(MockData.userProfile['avatar']),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                MockData.userProfile['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                MockData.userProfile['phone'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildDrawerItem(Icons.person_outline, 'Profile Settings', '/profile', context, const Color(0xFF038EF5)),
                  _buildDrawerItem(Icons.help_outline_rounded, 'Help & Support', '/help', context, const Color(0xFF32325D)),
                  _buildDrawerItem(Icons.info_outline_rounded, 'About Syncure', '/about', context, const Color(0xFF466EFC)),
                  _buildDrawerItem(Icons.privacy_tip_outlined, 'Privacy Policy', '/privacy', context, const Color(0xFF038EF5)),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: _buildLogoutItem(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route, BuildContext context, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF32325D),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF32325D),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF31260).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF31260).withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF31260).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Color(0xFFF31260),
            size: 20,
          ),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF31260),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final items = [
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'Home', 'route': '/dashboard'},
      {'icon': Icons.qr_code_outlined, 'activeIcon': Icons.qr_code, 'label': 'QR', 'route': '/qr'},
      {'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today, 'label': 'Appts', 'route': '/appointments'},
      {'icon': Icons.account_balance_wallet_outlined, 'activeIcon': Icons.account_balance_wallet, 'label': 'Payments', 'route': '/payments'},
      {'icon': Icons.medical_services_outlined, 'activeIcon': Icons.medical_services, 'label': 'History', 'route': '/medical-history'},
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFF31260),
      unselectedItemColor: AppTheme.textSecondary,
      currentIndex: items.indexWhere((item) => item['route'] == currentRoute),
      onTap: (index) => context.go(items[index]['route'] as String),
      items: items.map((item) {
        final isActive = currentRoute == item['route'];
        return BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          activeIcon: Icon(item['activeIcon'] as IconData),
          label: item['label'] as String,
        );
      }).toList(),
    );
  }
}