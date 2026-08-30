import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/river_zone.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class RiverZonesScreen extends StatefulWidget {
  const RiverZonesScreen({super.key});

  @override
  State<RiverZonesScreen> createState() => _RiverZonesScreenState();
}

class _RiverZonesScreenState extends State<RiverZonesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();

  List<RiverZone> _zones = [];
  bool _isLoading = true;
  String? _errorMessage;
  RiverZone? _selectedZone;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRiverZones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRiverZones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final zones = await ApiClient.instance.fetchRiverZones();
      setState(() {
        _zones = zones;
        _isLoading = false;
        if (zones.isNotEmpty) {
          _selectedZone = zones.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load river safety zones ($e)';
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return const Color(0xFF2E7D32);
      case 'MODERATE':
        return const Color(0xFFF57F17);
      case 'HIGH':
        return const Color(0xFFE65100);
      case 'CRITICAL':
      default:
        return const Color(0xFFC62828);
    }
  }

  void _focusZoneOnMap(RiverZone zone) {
    setState(() {
      _selectedZone = zone;
    });
    _tabController.animateTo(1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(zone.position, 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chandrabhaga Zones'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRiverZones,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt_rounded), text: 'Zone List'),
            Tab(icon: Icon(Icons.map_rounded), text: 'Safety Map'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading Chandrabhaga Safety Zones...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListView(),
                    _buildMapView(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load safety zones',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRiverZones,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_zones.isEmpty) {
      return const Center(
        child: Text(
          'No river safety zones found.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadRiverZones,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Operational disclaimer
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFF81D4FA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.waves_rounded, color: Color(0xFF0288D1), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Simulated river flow & ghat safety capacity data for volunteer coordination.',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF01579B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._zones.map((zone) => _buildZoneCard(zone)),
        ],
      ),
    );
  }

  Widget _buildZoneCard(RiverZone zone) {
    final status = zone.calculatedStatus;
    final statusColor = _getStatusColor(status);
    final capacityPct = (zone.capacityPercentage * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: zone.restrictedEntry ? const Color(0xFFFFCDD2) : AppColors.border,
          width: zone.restrictedEntry ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Zone name & Status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: AppTypography.headlineMd.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (zone.marathiName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          zone.marathiName,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: statusColor.withAlpha(120)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Restricted Entry Banner if active
            if (zone.restrictedEntry)
              Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ ENTRY RESTRICTED — DO NOT ENTER RIVER',
                        style: TextStyle(
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2E7D32), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'ENTRY OPEN',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

            // Metrics Row: Headcount vs Safe Capacity & Flow Velocity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Crowd / Capacity',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${zone.currentHeadcount} / ${zone.safeCapacity}',
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Flow Speed',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 16, color: Color(0xFF0288D1)),
                          const SizedBox(width: 4),
                          Text(
                            '${zone.waterFlowSpeedKmh} m/s',
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Capacity Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: (zone.capacityPercentage).clamp(0.0, 1.0),
                      minHeight: 6.0,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$capacityPct%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Safety Warning if present
            if (zone.safetyWarning.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                zone.safetyWarning,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),

            // Actions row
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _focusZoneOnMap(zone),
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text('VIEW ON MAP'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    final defaultCenter = _zones.isNotEmpty
        ? _zones.first.position
        : const LatLng(17.6715, 75.3235);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: defaultCenter,
            initialZoom: 15.0,
            minZoom: 12.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sevakconnect.sevak_connect',
            ),
            MarkerLayer(
              markers: _zones.map((zone) {
                final isSelected = _selectedZone?.id == zone.id;
                final statusColor = _getStatusColor(zone.calculatedStatus);

                return Marker(
                  point: zone.position,
                  width: isSelected ? 52 : 42,
                  height: isSelected ? 52 : 42,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedZone = zone);
                      _mapController.move(zone.position, 16.0);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: isSelected ? 3.0 : 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isSelected ? 90 : 50),
                            blurRadius: isSelected ? 10 : 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        zone.restrictedEntry
                            ? Icons.warning_rounded
                            : Icons.waves_rounded,
                        color: Colors.white,
                        size: isSelected ? 26 : 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Bottom Selected Zone Card
        if (_selectedZone != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 6,
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedZone!.restrictedEntry
                              ? Icons.warning_amber_rounded
                              : Icons.waves_rounded,
                          color: _getStatusColor(_selectedZone!.calculatedStatus),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedZone!.name,
                                style: AppTypography.headlineMd.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_selectedZone!.marathiName.isNotEmpty)
                                Text(
                                  _selectedZone!.marathiName,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_selectedZone!.calculatedStatus).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedZone!.calculatedStatus,
                            style: TextStyle(
                              color: _getStatusColor(_selectedZone!.calculatedStatus),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Crowd: ${_selectedZone!.currentHeadcount} / ${_selectedZone!.safeCapacity}',
                          style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Flow: ${_selectedZone!.waterFlowSpeedKmh} m/s',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF0288D1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedZone!.restrictedEntry ? '⚠️ RESTRICTED' : '✅ OPEN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _selectedZone!.restrictedEntry
                                ? const Color(0xFFC62828)
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
