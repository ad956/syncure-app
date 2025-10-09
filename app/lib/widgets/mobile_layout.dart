import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:heroicons/heroicons.dart';
import '../themes/app_theme.dart';
import '../services/novu_service.dart';

class MobileLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MobileLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout>
    with TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerAnimation;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _drawerAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: widget.child,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF6366F1),
              size: 22,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ),
      title: _getTitle(),
      actions: [
        FutureBuilder<List<NotificationItem>>(
          future: NovuService.getNotifications(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 2;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  NovuService.showNotifications(context);
                },
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Notifications',
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF31260), width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/images/admin.png'),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (context, child) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                        _drawerAnimation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF8B5CF6),
                        const Color(0xFF06B6D4),
                        _drawerAnimation.value,
                      )!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage('assets/images/admin.png'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'John Doe',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                '+91 9876543210',
                                style: TextStyle(
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
            );
            },
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildDrawerItem(HeroIcons.user, 'Profile Settings', '/profile', context, const Color(0xFF038EF5)),
                  _buildDrawerItem(HeroIcons.questionMarkCircle, 'Help & Support', '/help', context, const Color(0xFF32325D)),
                  _buildDrawerItem(HeroIcons.informationCircle, 'About Syncure', '/about', context, const Color(0xFF466EFC)),
                  _buildDrawerItem(HeroIcons.shieldCheck, 'Privacy Policy', '/privacy', context, const Color(0xFF038EF5)),
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

  Widget _buildDrawerItem(dynamic icon, String title, String route, BuildContext context, Color iconColor) {
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
          child: icon is IconData 
            ? Icon(icon, color: iconColor, size: 20)
            : HeroIcon(
                icon as HeroIcons,
                style: HeroIconStyle.outline,
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
          child: const HeroIcon(
            HeroIcons.arrowRightOnRectangle,
            style: HeroIconStyle.outline,
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
      currentIndex: items.indexWhere((item) => item['route'] == widget.currentRoute) != -1 
          ? items.indexWhere((item) => item['route'] == widget.currentRoute) 
          : 0,
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

  Widget _getTitle() {
    switch (widget.currentRoute) {
      case '/book-appointment':
        return const Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
      case '/chat':
        return const Text('Chat with Doctor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
      case '/lab-results':
        return const Text('Lab Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
      case '/doctors':
        return const Text('My Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
      default:
        return Row(
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
        );
    }
  }
}