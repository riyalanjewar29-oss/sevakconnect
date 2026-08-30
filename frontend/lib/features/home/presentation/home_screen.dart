import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/domain/models/user_session.dart';
import '../../common/presentation/feature_placeholder_screen.dart';
import '../../../core/network/api_client.dart';
import '../../crowd/presentation/crowd_report_screen.dart';
import '../../crowd/presentation/live_crowd_map_screen.dart';
import '../../routing/presentation/crowd_route_screen.dart';
import '../../supplies/presentation/camp_supplies_screen.dart';
import '../../facilities/presentation/facilities_screen.dart';
import '../../river/presentation/river_zones_screen.dart';
import 'package:geolocator/geolocator.dart';
import '../../alerts/presentation/alerts_screen.dart';
import '../../missing_person/presentation/missing_person_screen.dart';
import '../../halt/presentation/halt_readiness_screen.dart';
import '../../tasks/presentation/tasks_screen.dart';

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

  void _toggleNetworkState() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  void _showEmergencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emergency_rounded,
                        color: Color(0xFFC62828),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMERGENCY SOS',
                            style: AppTypography.headlineLg.copyWith(
                              color: const Color(0xFFC62828),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Immediate Command Assistance',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Are you sure you want to send an emergency SOS?\n\n'
                  'Your current live GPS location will be broadcast to Sector 4 Command Center, Quick Response Teams, and nearby Sevaks.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(bottomSheetContext);
                          _dispatchSos();
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'SEND SOS',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _dispatchSos() async {
    BuildContext? loadingCtx;
    // Show progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) {
        loadingCtx = dCtx;
        return const PopScope(
          canPop: false,
          child: Center(
            child: Card(
              margin: EdgeInsets.all(24),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFC62828)),
                    SizedBox(height: 20),
                    Text(
                      'Acquiring GPS location & broadcasting SOS...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    double? lat;
    double? lng;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {}

    // Fallback coordinates if GPS simulator timeout
    lat ??= 17.6750;
    lng ??= 75.3240;

    final reporterName = UserSession.instance.userState.fullName.trim();
    final result = await ApiClient.instance.triggerSos(
      latitude: lat,
      longitude: lng,
      reportedBy: reporterName.isNotEmpty ? reporterName : 'volunteer_demo',
      description: 'Critical SOS emergency triggered by field Sevak.',
    );

    // Dismiss loading dialog safely
    if (loadingCtx != null && loadingCtx!.mounted && Navigator.canPop(loadingCtx!)) {
      Navigator.pop(loadingCtx!);
    }

    if (!mounted) return;

    if (result.isSuccess) {
      showDialog(
        context: context,
        builder: (successCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
              SizedBox(width: 10),
              Text('🚨 SOS SENT', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFC62828))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your emergency location has been shared with the coordination team.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMERGENCY ID:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.incidentId ?? 'SOS-CONFIRMED',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB71C1C),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'GPS: ${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: Color(0xFFC62828), size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Critical Alert broadcasted to all active volunteers.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(successCtx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Unable to send SOS. Please check connection and retry.'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
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
            // Left: SevakConnect Brand Logo
            Image.asset(
              'assets/images/sevakconnect_logo_transparent.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HaltReadinessScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
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
          const SizedBox(height: 12),
          // Interactive Action to Route to Safer Alternative
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CrowdRouteScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.alt_route_rounded, size: 16, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'High crowd reported ahead — Find safer route',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF2E7D32)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
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
        icon: Icons.layers_rounded,
        title: 'Chandrabhaga\nZones',
        description: 'River ghat sectors, bathing safety cordons, and rescue readiness.',
      ),
      _QuickActionItem(
        icon: Icons.notifications_active_outlined,
        title: 'Alerts',
        description: 'High-priority route diversions, safety warnings, and weather updates.',
      ),
      _QuickActionItem(
        icon: Icons.alt_route_rounded,
        title: 'Crowd-Aware\nRouting',
        description: 'Crowd-aware route evaluation and lower-congestion corridor recommendations.',
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
        onTap: () {
          final cleanTitle = item.title.replaceAll('\n', ' ');
          if (cleanTitle == 'Report Crowd') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CrowdReportScreen(),
              ),
            );
          } else if (cleanTitle == 'Camp Supplies') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CampSuppliesScreen(),
              ),
            );
          } else if (cleanTitle == 'Facilities') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FacilitiesScreen(),
              ),
            );
          } else if (cleanTitle == 'Missing Person') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MissingPersonScreen(),
              ),
            );
          } else if (cleanTitle == 'Crowd-Aware Routing' || cleanTitle == 'Safer Routes') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CrowdRouteScreen(),
              ),
            );
          } else if (cleanTitle == 'Chandrabhaga Zones') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RiverZonesScreen(),
              ),
            );
          } else if (cleanTitle == 'Alerts') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlertsScreen(),
              ),
            );
          } else {
            _openPlaceholder(cleanTitle, item.description, item.icon);
          }
        },
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
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3. Bottom Navigation Bar (Material 3 style with saffron active indicator pill)
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                icon: Icons.assignment_outlined,
                label: 'Tasks',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TasksScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.map_outlined,
                label: 'Map',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveCrowdMapScreen(),
                    ),
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
