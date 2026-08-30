import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';

/// Screen for viewing facility locations on OpenStreetMap with category-colored markers.
class FacilityMapScreen extends StatefulWidget {
  final FacilityItemData initialFacility;
  final List<FacilityItemData> allFacilities;

  const FacilityMapScreen({
    super.key,
    required this.initialFacility,
    required this.allFacilities,
  });

  @override
  State<FacilityMapScreen> createState() => _FacilityMapScreenState();
}

class _FacilityMapScreenState extends State<FacilityMapScreen> {
  final MapController _mapController = MapController();
  late FacilityItemData _selectedFacility;

  @override
  void initState() {
    super.initState();
    _selectedFacility = widget.initialFacility;
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

  @override
  Widget build(BuildContext context) {
    final focusCoord = LatLng(_selectedFacility.latitude, _selectedFacility.longitude);
    final statusColor = _getStatusColor(_selectedFacility.status);
    final categoryColor = _getCategoryColor(_selectedFacility.type);

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
          'Facility Map',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.primary),
            tooltip: 'Center on selected facility',
            onPressed: () {
              _mapController.move(focusCoord, 15.5);
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: focusCoord,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sevakconnect.sevak_connect',
              ),
              MarkerLayer(
                markers: widget.allFacilities.map((fac) {
                  final isSelected = fac.id == _selectedFacility.id;
                  final markerColor = _getCategoryColor(fac.type);
                  final markerIcon = _getCategoryIcon(fac.type);

                  return Marker(
                    point: LatLng(fac.latitude, fac.longitude),
                    width: isSelected ? 44 : 34,
                    height: isSelected ? 44 : 34,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFacility = fac);
                        _mapController.move(LatLng(fac.latitude, fac.longitude), 15.5);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: markerColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: isSelected ? 3.0 : 2.0,
                          ),
                          boxShadow: isSelected ? AppShadows.level2 : AppShadows.level1,
                        ),
                        child: Icon(
                          markerIcon,
                          color: Colors.white,
                          size: isSelected ? 22 : 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Bottom Facility Detail Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.level2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: categoryColor.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getCategoryIcon(_selectedFacility.type), color: categoryColor, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedFacility.type.toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: categoryColor, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withAlpha(80)),
                        ),
                        child: Text(
                          _selectedFacility.status,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFacility.name,
                    style: AppTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _selectedFacility.locationName,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (_selectedFacility.description != null && _selectedFacility.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _selectedFacility.description!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ],
                  if (_selectedFacility.contactInfo != null && _selectedFacility.contactInfo!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          _selectedFacility.contactInfo!,
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
