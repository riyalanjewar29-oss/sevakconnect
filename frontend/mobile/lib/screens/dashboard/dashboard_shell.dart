import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_dashboard_service.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/sidebar.dart';
import 'overview/overview_screen.dart';
import 'live_map/live_map_screen.dart';
import 'emergencies/emergencies_screen.dart';
import 'crowd_monitoring/crowd_monitoring_screen.dart';
import 'volunteers/volunteers_screen.dart';

import '../../services/auth/auth_service.dart';
import '../auth/login_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  DashboardNavTab _selectedTab = DashboardNavTab.overview;

  void _onTabSelected(DashboardNavTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  Future<void> _onLogout() async {
    try {
      await AuthService().signOut();
    } catch (e) {
      debugPrint('Signout notice: $e');
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final dashboardService = context.watch<AdminDashboardService>();
    final activeRole = dashboardService.activeRole;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: TopBar(
        title: _selectedTab == DashboardNavTab.overview ? 'Admin Dashboard' : _selectedTab.title,
        activeRole: activeRole,
        onRoleToggle: () => dashboardService.toggleRole(),
        onMenuPressed: !isDesktop ? () => Scaffold.of(context).openDrawer() : null,
        onLogout: _onLogout,
      ),
      drawer: !isDesktop
          ? Drawer(
              child: Sidebar(
                selectedTab: _selectedTab,
                onTabSelected: (tab) {
                  _onTabSelected(tab);
                  Navigator.of(context).pop();
                },
                onLogout: _onLogout,
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Desktop Fixed Sidebar
          if (isDesktop)
            Sidebar(
              selectedTab: _selectedTab,
              onTabSelected: _onTabSelected,
              onLogout: _onLogout,
            ),

          // Main Content Area (Fluid Container)
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  padding: const EdgeInsets.all(24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(_selectedTab),
                      child: _buildPageContent(_selectedTab),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(DashboardNavTab tab) {
    switch (tab) {
      case DashboardNavTab.overview:
        return OverviewScreen(
          onNavigateToMap: () => _onTabSelected(DashboardNavTab.liveMap),
          onNavigateToEmergencies: () => _onTabSelected(DashboardNavTab.emergencies),
          onNavigateToCrowd: () => _onTabSelected(DashboardNavTab.crowdMonitoring),
          onNavigateToVolunteers: () => _onTabSelected(DashboardNavTab.volunteers),
        );
      case DashboardNavTab.liveMap:
        return const LiveMapScreen();
      case DashboardNavTab.emergencies:
        return const EmergenciesScreen();
      case DashboardNavTab.crowdMonitoring:
        return const CrowdMonitoringScreen();
      case DashboardNavTab.volunteers:
        return const VolunteersScreen();
    }
  }
}
