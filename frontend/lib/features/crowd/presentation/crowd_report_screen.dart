import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/extensions/crowd_level_extension.dart';
import '../../../core/models/crowd_condition.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../auth/domain/models/user_session.dart';
import 'live_crowd_map_screen.dart';

/// Screen for reporting live crowd density and flow conditions with GPS tagging.
class CrowdReportScreen extends StatefulWidget {
  final CrowdLevel? initialLevel;

  const CrowdReportScreen({
    super.key,
    this.initialLevel,
  });

  @override
  State<CrowdReportScreen> createState() => _CrowdReportScreenState();
}

class _CrowdReportScreenState extends State<CrowdReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _headcountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final MapController _mapController = MapController();

  // Crowd State
  late CrowdLevel _selectedLevel;
  String _selectedDirection = 'Towards Pandharpur';

  // GPS & Map State
  LatLng? _currentLocation;
  bool _isLocating = false;
  String? _locationErrorMessage;
  bool _locationConfirmed = false;

  // Submission State
  bool _isSubmitting = false;

  final List<String> _directionOptions = [
    'Towards Pandharpur',
    'Stationary / Congested',
    'Dispersing / Outflow',
    'Moving Along Ring Road',
    'Other / Unspecified',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel ?? CrowdLevel.high;
  }

  @override
  void dispose() {
    _headcountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Requests permissions and captures high-accuracy GPS coordinates.
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationErrorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationErrorMessage =
              'Location services are disabled on your device. Please enable GPS.';
          _isLocating = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationErrorMessage =
                'Location permission was denied. Please grant location access.';
            _isLocating = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationErrorMessage =
              'Location permissions are permanently denied. Please update App Settings.';
          _isLocating = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = point;
        _locationConfirmed = true;
        _isLocating = false;
        _locationErrorMessage = null;
      });

      // Recenter map safely on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            _mapController.move(point, 16.0);
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('[CrowdReportScreen] Location error: $e');
      setState(() {
        _locationErrorMessage =
            'Could not retrieve GPS coordinates ($e). Please check GPS signal.';
        _isLocating = false;
      });
    }
  }

  /// Submits the crowd condition report to FastAPI backend and SQLite.
  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.statusCritical,
          content: Text('Please capture and confirm your location before submitting.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final fullName = UserSession.instance.userState.fullName.trim();
    final reportedBy = fullName.isNotEmpty ? fullName : 'volunteer_demo';

    int? headcount;
    if (_headcountController.text.trim().isNotEmpty) {
      headcount = int.tryParse(_headcountController.text.trim());
    }

    final result = await ApiClient.instance.createCrowdReport(
      crowdLevel: _selectedLevel.name,
      estimatedHeadcount: headcount,
      movementDirection: _selectedDirection,
      description: _descriptionController.text.trim(),
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      reportedBy: reportedBy,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result.isSuccess && result.reportId != null) {
      _showSuccessDialog(result.reportId!, result.createdAt);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusCritical,
          content: Text(
            result.errorMessage ?? 'Failed to submit crowd report. Please try again.',
          ),
        ),
      );
    }
  }

  void _showSuccessDialog(String reportId, String? createdAt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Crowd Report Stored',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crowd condition recorded and synced to the command database.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'REPORT ID',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _selectedLevel.containerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedLevel.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _selectedLevel.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      reportId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Divider(height: 16, color: AppColors.border),
                    Text(
                      'Direction: $_selectedDirection',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    if (_headcountController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Estimated Headcount: ${_headcountController.text.trim()} people',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'GPS: ${_currentLocation!.latitude.toStringAsFixed(5)}, ${_currentLocation!.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            PrimaryButton(
              text: 'VIEW ON LIVE CROWD MAP',
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveCrowdMapScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              text: 'Return to Dashboard',
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.of(context).pop(); // Pop back to dashboard
              },
            ),
          ],
        );
      },
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
          'Report Crowd Condition',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Crowd Level
                _buildSectionHeader('1. CROWD CONDITION LEVEL', Icons.groups_rounded),
                const SizedBox(height: 8),
                Row(
                  children: CrowdLevel.values.map((level) {
                    final isSelected = _selectedLevel == level;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedLevel = level),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? level.color : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? level.color : AppColors.border,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected ? AppShadows.level1 : null,
                            ),
                            child: Center(
                              child: Text(
                                level.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Section 2: Flow & Headcount
                _buildSectionHeader('2. CROWD FLOW & HEADCOUNT (OPTIONAL)', Icons.trending_up_rounded),
                const SizedBox(height: 8),

                // Movement Direction Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDirection,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      items: _directionOptions.map((dir) {
                        return DropdownMenuItem<String>(
                          value: dir,
                          child: Text(
                            dir,
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDirection = val);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Headcount Field
                TextFormField(
                  controller: _headcountController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyMd,
                  decoration: InputDecoration(
                    labelText: 'Approximate Headcount',
                    hintText: 'e.g. 200, 500, 1000...',
                    prefixIcon: const Icon(Icons.people_outline_rounded, color: AppColors.primary, size: 20),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Section 3: Description Field
                _buildSectionHeader('3. OBSERVATION NOTES (OPTIONAL)', Icons.edit_note_rounded),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: AppTypography.bodyMd,
                  decoration: InputDecoration(
                    hintText: 'e.g. Movement slowing near junction, water stall crowding...',
                    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Section 4: Location Capture & Map
                _buildSectionHeader('4. CURRENT LOCATION', Icons.location_on_rounded),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLocating ? null : _getCurrentLocation,
                    icon: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.my_location_rounded, size: 20),
                    label: Text(
                      _isLocating ? 'ACQUIRING GPS...' : 'USE CURRENT LOCATION',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                if (_locationErrorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusCriticalContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusCritical.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.statusCritical, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _locationErrorMessage!,
                            style: const TextStyle(fontSize: 12, color: AppColors.onStatusCritical),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_currentLocation != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'GPS Coordinates:',
                          style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLocation!,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.sevakconnect.sevak_connect',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLocation!,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectedLevel.color,
                                    shape: BoxShape.circle,
                                    boxShadow: AppShadows.level2,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _locationConfirmed,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _locationConfirmed = val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'I confirm this location marks the crowd observation spot.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),

                PrimaryButton(
                  text: 'SUBMIT CROWD REPORT',
                  isLoading: _isSubmitting,
                  loadingText: 'TRANSMITTING CROWD REPORT...',
                  onPressed: (_isSubmitting || _currentLocation == null)
                      ? null
                      : _submitReport,
                ),

                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTypography.labelSm.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
