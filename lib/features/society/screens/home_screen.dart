import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/constants/api_constants.dart';
import 'package:society_management_app/core/constants/constants_values.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/core/storage/token_storage.dart';
import 'package:society_management_app/features/announcements/presentation/screens/announcement_screen.dart';
import 'package:society_management_app/features/announcements/presentation/screens/todays_announcement_widget.dart';
import 'package:society_management_app/features/auth/presentation/screens/initial_screen.dart';
import 'package:society_management_app/features/chats/presentation/screens/chat_list_screen.dart';
import 'package:society_management_app/features/posts/presentation/screens/post_screen.dart';
import 'package:society_management_app/features/society/bloc/nav_bloc.dart';
import 'package:society_management_app/features/society/bloc/nav_event.dart';
import 'package:society_management_app/features/society/bloc/nav_state.dart';
import 'package:society_management_app/features/user/presentation/screens/user_screen.dart';
import 'package:society_management_app/features/visitors/presentation/screens/visitor_screen.dart';

// ─── Temporary placeholders for role/userId ──────────────────────────────────
// Replace these with values from your auth state / shared prefs

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => NavBloc(), child: const _HomeView());
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  // Tabs visible to ALL users
  static const List<_TabConfig> _allTabs = [
    _TabConfig(
      index: 0,
      label: "Home",
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _TabConfig(
      index: 1,
      label: "Community",
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum,
    ),
    _TabConfig(
      index: 2,
      label: "Visitors",
      icon: Icons.badge_outlined,
      activeIcon: Icons.badge,
    ),
    _TabConfig(
      index: 3,
      label: "Notices",
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign,
    ),
    // Admin-only tab (index 4)
    _TabConfig(
      index: 4,
      label: "Members",
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      adminOnly: true,
    ),
  ];

  List<_TabConfig> _visibleTabs(bool isAdmin) =>
      _allTabs.where((t) => !t.adminOnly || isAdmin).toList();

  @override
  Widget build(BuildContext context) {
    final isAdmin = ConstantsValue.currentUser?.role == "admin";
    final tabs = _visibleTabs(isAdmin);

    return BlocBuilder<NavBloc, NavState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: tabs.map((t) => _buildPage(t.index, isAdmin)).toList(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.currentIndex,
            onDestinationSelected: (i) =>
                context.read<NavBloc>().add(NavTabChanged(i)),
            destinations: tabs
                .map(
                  (t) => NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.activeIcon),
                    label: t.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildPage(int index, bool isAdmin) {
    switch (index) {
      case 0:
        return const _DashboardTab();
      case 1:
        return PostScreen();
      case 2:
        return VisitorScreen();
      case 3:
        return AnnouncementScreen();
      case 4:
        return UserScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Dashboard / Home tab ─────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Society"),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Today's announcements carousel ──────────────────
              const TodayAnnouncementsWidget(),

              const SizedBox(height: 16),

              // ── Quick-action grid ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Quick Actions",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    _QuickCard(
                      icon: Icons.forum_outlined,
                      label: "Community",
                      color: Colors.blue,
                      onTap: () =>
                          context.read<NavBloc>().add(const NavTabChanged(1)),
                    ),
                    _QuickCard(
                      icon: Icons.badge_outlined,
                      label: "Visitors",
                      color: Colors.orange,
                      onTap: () =>
                          context.read<NavBloc>().add(const NavTabChanged(2)),
                    ),

                    if (ConstantsValue.currentUser?.role == "admin")
                      _QuickCard(
                        icon: Icons.campaign_outlined,
                        label: "Notices",
                        color: Colors.green,
                        onTap: () =>
                            context.read<NavBloc>().add(const NavTabChanged(3)),
                      ),
                    if (ConstantsValue.currentUser?.role == "admin")
                      _QuickCard(
                        icon: Icons.group_outlined,
                        label: "Members",
                        color: Colors.purple,
                        onTap: () =>
                            context.read<NavBloc>().add(const NavTabChanged(4)),
                      ),

                    _QuickCard(
                      icon: Icons.group_outlined,
                      label: "Chats",
                      color: Colors.cyan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatListScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await sl<TokenStorage>().clearToken();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => InitialScreen()),
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Quick-action card ────────────────────────────────────────────────────────

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: color.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab config model ─────────────────────────────────────────────────────────

class _TabConfig {
  final int index;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool adminOnly;

  const _TabConfig({
    required this.index,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.adminOnly = false,
  });
}
