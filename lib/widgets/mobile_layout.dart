import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter/cupertino.dart';
import '../themes/app_theme.dart';
import '../services/novu_service.dart';
import '../providers/auth_provider.dart';

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

class _MobileLayoutState extends State<MobileLayout> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: widget.child,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,

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
                    color: Colors.black.withOpacity(0.08),
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
                      Iconsax.notification,
                      color: Color(0xFF6366F1),
                      size: 26,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final user = ref.watch(authProvider).user;
            final profileImage = user?.image;
            
            return PopupMenuButton<String>(
              offset: const Offset(0, 50),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF31260), width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: profileImage != null && profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : const AssetImage('assets/images/admin.png') as ImageProvider,
                ),
              ),
              itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.user,
                      color: Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Profile Settings'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF31260).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.logout,
                      color: Color(0xFFF31260),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Logout',
                    style: TextStyle(color: Color(0xFFF31260)),
                  ),
                ],
              ),
            ),
          ],
              onSelected: (String value) {
                switch (value) {
                  case 'profile':
                    context.go('/profile');
                    break;
                  case 'logout':
                    context.go('/login');
                    break;
                }
              },
            );
          },
        ),
      ],
    );
  }







  Widget _buildBottomNavBar(BuildContext context) {
    final items = [
      {'icon': Iconsax.home_1, 'activeIcon': Iconsax.home_15, 'label': 'Home', 'route': '/dashboard'},
      {'icon': Iconsax.message, 'activeIcon': Iconsax.message5, 'label': 'Chat', 'route': '/chat'},
      {'icon': Iconsax.calendar, 'activeIcon': Iconsax.calendar5, 'label': 'Appts', 'route': '/appointments'},
      {'icon': Iconsax.card, 'activeIcon': Iconsax.card5, 'label': 'Pay', 'route': '/payments'},
      {'icon': Iconsax.health, 'activeIcon': Iconsax.health5, 'label': 'Records', 'route': '/health-records'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: items.indexWhere((item) => item['route'] == widget.currentRoute) != -1 
            ? items.indexWhere((item) => item['route'] == widget.currentRoute) 
            : 0,
        onTap: (index) => context.go(items[index]['route'] as String),
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData, size: 22),
            activeIcon: Icon(item['activeIcon'] as IconData, size: 22),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }

  Widget _getTitle() {
    switch (widget.currentRoute) {
      case '/chat':
        return const Text('Chat with Doctor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
      case '/lab-results':
        return const Text('Lab Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
      case '/doctors':
        return const Text('My Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
      case '/chat':
        return const Text('Chat with Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF32325D)));
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