import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import 'facility_map_screen.dart';

/// Screen for browsing and filtering essential Wari pilgrimage facilities.
class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _errorMessage;
  List<FacilityItemData> _facilities = [];
  Position? _currentPosition;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'type': 'All'},
    {'name': 'Medical', 'icon': Icons.medical_services_rounded, 'type': 'medical'},
    {'name': 'Water', 'icon': Icons.water_drop_rounded, 'type': 'water'},
    {'name': 'Toilets', 'icon': Icons.wc_rounded, 'type': 'toilets'},
    {'name': 'Food', 'icon': Icons.restaurant_rounded, 'type': 'food'},
    {'name': 'Security', 'icon': Icons.security_rounded, 'type': 'security'},
  ];

  @override
  void initState() {
    super.initState();
    _tryGetGpsLocation();
    _loadFacilities();
  }

  Future<void> _tryGetGpsLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (mounted) {
        setState(() => _currentPosition = pos);
      }
    } catch (_) {}
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiClient.instance.fetchFacilities(
        type: _selectedCategory == 'All' ? null : _selectedCategory,
      );

      if (mounted) {
        setState(() {
          _facilities = items;
          _isLoading = false;
          if (items.isEmpty) {
            _errorMessage = 'No facilities found for category: $_selectedCategory.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load live facility data. Please try again.';
        });
      }
    }
  }

  double? _calculateDistanceKm(double lat, double lng) {
    if (_currentPosition == null) return null;
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );
    return double.parse((meters / 1000.0).toStringAsFixed(1));
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical':
        return Icons.medical_services_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'toilets':
        return Icons.wc_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'medical':
        return const Color(0xFFC62828);
      case 'water':
        return const Color(0xFF0288D1);
      case 'toilets':
        return const Color(0xFF5D4037);
      case 'food':
        return const Color(0xFFF57C00);
      case 'security':
        return const Color(0xFF1565C0);
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'AVAILABLE':
        return AppColors.statusNormal;
      case 'LIMITED':
        return AppColors.statusModerate;
      case 'CLOSED':
        return AppColors.statusCritical;
      default:
        return AppColors.textSecondary;
    }
  }

  void _openFacilityOnMap(FacilityItemData fac) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacilityMapScreen(
          initialFacility: fac,
          allFacilities: _facilities,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Essential Facilities',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh facilities',
            onPressed: _loadFacilities,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Horizontal Chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory.toLowerCase() == (cat['type'] as String).toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 14,
                              color: isSelected ? Colors.white : AppColors.secondary,
                            ),
                            const SizedBox(width: 5),
                            Text(cat['name'] as String),
                          ],
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.secondary,
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat['type'] as String);
                            _loadFacilities();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            if (_errorMessage != null && _facilities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.statusCritical, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, color: AppColors.statusCritical, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Facilities List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFacilities,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _facilities.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final fac = _facilities[index];
                          return _buildFacilityCard(fac);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(FacilityItemData fac) {
    final statusColor = _getStatusColor(fac.status);
    final categoryColor = _getCategoryColor(fac.type);
    final categoryIcon = _getCategoryIcon(fac.type);
    final distKm = _calculateDistanceKm(fac.latitude, fac.longitude);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fac.name,
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  fac.locationName,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (distKm != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• $distKm km away',
                                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Text(
                  fac.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          if (fac.description != null && fac.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              fac.description!,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (fac.contactInfo != null && fac.contactInfo!.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fac.contactInfo!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Spacer(),

              // VIEW ON MAP button
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer.withAlpha(50),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.map_rounded, size: 14),
                label: const Text('VIEW ON MAP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _openFacilityOnMap(fac),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
