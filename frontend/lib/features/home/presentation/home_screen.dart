import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../auth/domain/models/user_session.dart';
import '../../common/presentation/feature_placeholder_screen.dart';
import '../../../core/network/api_client.dart';

/// SevakConnect Main Dashboard / Home Screen
/// Built strictly following the reference screenshot and DESIGN.md tokens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = true;
  int _selectedNavIndex = 0;
  BackendHealthResult? _backendHealth;

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    final result = await ApiClient.instance.checkHealth();
    if (mounted) {
      setState(() {
        _backendHealth = result;
      });
    }
  }

  void _toggleNetworkState() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  String get _userInitials {
    final name = UserSession.instance.userState.fullName.trim();
    if (name.isEmpty) return 'SC';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  void _showEmergencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: AppShadows.level2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.statusCritical, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Emergency SOS Dispatch',
                    style: AppTypography.headlineLg.copyWith(color: AppColors.statusCritical),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Broadcast emergency assistance alert to Sector 4 Command Center & Nearby Sevaks.',
                style: AppTypography.bodyLg,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'CONFIRM EMERGENCY BROADCAST',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.statusCritical,
                      content: Text('Emergency SOS broadcast sent to Command Center'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPlaceholder(String title, String description, IconData icon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeaturePlaceholderScreen(
          title: title,
          description: description,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16.0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Left: Circular user/profile image
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.primaryContainer.withAlpha(200),
              child: Text(
                _userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title: SevakConnect
            Text(
              AppConstants.appName,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        actions: [
          // Developer/Test Backend Health Indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: InkWell(
              onTap: _checkBackendHealth,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (_backendHealth?.isConnected ?? false)
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_backendHealth?.isConnected ?? false)
                        ? const Color(0xFF81C784)
                        : const Color(0xFFE57373),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (_backendHealth?.isConnected ?? false)
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 13,
                      color: (_backendHealth?.isConnected ?? false)
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (_backendHealth?.isConnected ?? false)
                          ? 'CONNECTED ✓'
                          : 'NOT CONNECTED ✕',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: (_backendHealth?.isConnected ?? false)
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Right: Connectivity / offline icon
          IconButton(
            icon: Icon(
              _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: _isOnline ? AppColors.statusNormal : AppColors.statusCritical,
              size: 24,
            ),
            tooltip: _isOnline ? 'Online (Tap to toggle)' : 'Offline (Tap to toggle)',
            onPressed: _toggleNetworkState,
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: AppColors.border,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner if disconnected
            if (!_isOnline)
              OfflineBanner(
                isOnline: _isOnline,
                onToggleState: _toggleNetworkState,
              ),

            // Scrollable dashboard content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Next Halt Card
                    _buildNextHaltCard(),

                    const SizedBox(height: 24),

                    // 2. Quick Actions Section
                    Text(
                      'QUICK ACTIONS',
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2-Column Responsive Grid
                    _buildQuickActionsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating SOS button positioned above bottom navigation
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SizedBox(
          width: 58,
          height: 58,
          child: FloatingActionButton(
            heroTag: 'sos_fab',
            backgroundColor: AppColors.statusCritical,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () => _showEmergencyBottomSheet(context),
            child: const Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 1. Next Halt / Operational Status Card
  Widget _buildNextHaltCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT HALT',
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wakhari Phata',
                      style: AppTypography.headlineLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'ETA: 14:30 HRS',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // High Crowd filled status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8F4E00), // Saffron / brown filled pill
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'High Crowd',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Projected Needs Lighter Inner Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7F4),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.border.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROJECTED NEEDS',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildNeedChip(Icons.water_drop_rounded, 'Water (200L)'),
                    _buildNeedChip(Icons.medical_services_rounded, 'Medical Tents (2)'),
                    _buildNeedChip(Icons.wc_rounded, 'Mobile Toilets (5)'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Quick Actions 2-Column Responsive Grid
  Widget _buildQuickActionsGrid() {
    final actions = [
      _QuickActionItem(
        icon: Icons.groups_rounded,
        title: 'Report Crowd',
        description: 'Submit real-time crowd density observations and bottleneck reports.',
      ),
      _QuickActionItem(
        icon: Icons.inventory_2_rounded,
        title: 'Camp Supplies',
        description: 'Track ration stock, drinking water barrels, and medical aid items.',
      ),
      _QuickActionItem(
        icon: Icons.apartment_rounded,
        title: 'Facilities',
        description: 'Locate mobile toilets, resting shelters, and drinking water kiosks.',
      ),
      _QuickActionItem(
        icon: Icons.person_search_rounded,
        title: 'Missing Person',
        description: 'File lost person reports or verify reunited warkaris.',
      ),
      _QuickActionItem(
        icon: Icons.remove_red_eye_rounded,
        title: 'Darshan Status',
        description: 'Live Mukhdarshan and Charan Sparsh wait times and entry gates.',
      ),
      _QuickActionItem(
        icon: Icons.layers_rounded,
        title: 'Chandrabhaga\nZones',
        description: 'River ghat sectors, bathing safety cordons, and rescue readiness.',
      ),
      _QuickActionItem(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Chat',
        description: 'Volunteer channel communications and coordinator announcements.',
      ),
      _QuickActionItem(
        icon: Icons.notifications_active_outlined,
        title: 'Alerts',
        description: 'High-priority route diversions, safety warnings, and weather updates.',
      ),
      _QuickActionItem(
        icon: Icons.how_to_reg_rounded,
        title: 'Darshan\nRegistration',
        description: 'Darshan registration will be implemented next.',
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.16,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return _buildActionCard(item);
      },
    );
  }

  Widget _buildActionCard(_QuickActionItem item) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () => _openPlaceholder(item.title.replaceAll('\n', ' '), item.description, item.icon),
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withAlpha(6),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3. Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () {
                  setState(() => _selectedNavIndex = 0);
                },
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                onTap: () {
                  _openPlaceholder(
                    'Chat',
                    'Direct communication with volunteers and central command.',
                    Icons.chat_bubble_outline_rounded,
                  );
                },
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.assignment_outlined,
                label: 'Tasks',
                onTap: () {
                  _openPlaceholder(
                    'Tasks',
                    'Assigned volunteer duties, checkpoint logs, and shift tasks.',
                    Icons.assignment_outlined,
                  );
                },
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.map_outlined,
                label: 'Map',
                onTap: () {
                  _openPlaceholder(
                    'Map',
                    'Live route navigation, ring road sectors, and medical posts.',
                    Icons.map_outlined,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedNavIndex == index;

    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0), // Saffron-tinted pill
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String title;
  final String description;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
