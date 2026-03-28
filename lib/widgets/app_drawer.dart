import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.userName;
    final userEmail = AuthService.userEmail;
    final groupName = AuthService.groupName;
    final isAdmin = AuthService.isAdmin;

    return Drawer(
      backgroundColor: AppTheme.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.deepPurple, AppTheme.surfaceDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.accentOrange.withAlpha(40),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 12,
                    ),
                  ),
                  if (groupName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        groupName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.history_outlined,
              label: 'My Predictions',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-predictions');
              },
            ),
            _DrawerItem(
              icon: Icons.leaderboard_outlined,
              label: 'Leaderboard',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/leaderboard');
              },
            ),
            _DrawerItem(
              icon: Icons.emoji_events_outlined,
              label: 'Points Rubric',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/points-rubric');
              },
            ),
            if (isAdmin) ...[
              const Divider(color: Colors.white12, indent: 16, endIndent: 16),
              _DrawerItem(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Admin Panel',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
              _DrawerItem(
                icon: Icons.groups_outlined,
                label: 'Manage Groups',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin-groups');
                },
              ),
            ],
            const Spacer(),
            const Divider(color: Colors.white12, indent: 16, endIndent: 16),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              color: Colors.redAccent,
              onTap: () async {
                await AuthService.signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withAlpha(200);

    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: c,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: Colors.white.withAlpha(10),
    );
  }
}
