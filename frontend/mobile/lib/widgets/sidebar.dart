import 'package:flutter/material.dart';
import 'sevak_logo.dart';
import 'profile_dialog.dart';
import 'logout_dialog.dart';

enum DashboardNavTab {
  overview('Overview', Icons.grid_view_rounded),
  liveMap('Live Map', Icons.location_on_outlined),
  emergencies('Emergencies', Icons.warning_amber_rounded),
  crowdMonitoring('Crowd Monitoring', Icons.groups_outlined),
  volunteers('Volunteers', Icons.badge_outlined);

  final String title;
  final IconData icon;
  const DashboardNavTab(this.title, this.icon);
}

class Sidebar extends StatelessWidget {
  final DashboardNavTab selectedTab;
  final ValueChanged<DashboardNavTab> onTabSelected;
  final VoidCallback? onLogout;

  const Sidebar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Branding
          const SizedBox(height: 20),
          const SevakLogo(size: 130),
          const SizedBox(height: 20),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: DashboardNavTab.values.map((tab) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildNavItem(tab),
                );
              }).toList(),
            ),
          ),

          // Bottom Actions: Profile & Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              children: [
                _buildBottomItem(
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  onTap: () => showProfileDialog(context),
                ),
                const SizedBox(height: 4),
                _buildBottomItem(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  onTap: () => showLogoutDialog(
                    context,
                    onLogout: onLogout ?? () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(DashboardNavTab tab) {
    final isSelected = selectedTab == tab;
    const activeColor = Color(0xFFFF6600);
    const activeBgColor = Color(0xFFFFF3E8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTabSelected(tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? const Border(
                    left: BorderSide(color: activeColor, width: 3.5),
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                tab.icon,
                size: 20,
                color: isSelected ? activeColor : const Color(0xFF4A4A4A),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  tab.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isSelected ? activeColor : const Color(0xFF333333),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF4A4A4A),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
