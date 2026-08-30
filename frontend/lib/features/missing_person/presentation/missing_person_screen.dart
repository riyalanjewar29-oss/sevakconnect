import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/lost_found_case.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class MissingPersonScreen extends StatefulWidget {
  const MissingPersonScreen({super.key});

  @override
  State<MissingPersonScreen> createState() => _MissingPersonScreenState();
}

class _MissingPersonScreenState extends State<MissingPersonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  String? _selectedGender;
  bool _isMinor = false;
  double? _selectedLat;
  double? _selectedLng;
  bool _isLocating = false;
  bool _isSubmitting = false;

  // Photo attachment
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Directory list state
  List<LostFoundCase> _cases = [];
  bool _isLoadingDirectory = true;
  String? _directoryError;
  String _selectedFilter = 'All';

  final MapController _miniMapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setCurrentLocationDefault();
    _loadDirectory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _setCurrentLocationDefault() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
        setState(() {
          _selectedLat = pos.latitude;
          _selectedLng = pos.longitude;
          _isLocating = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback default coordinate in Pandharpur
    setState(() {
      _selectedLat = 17.6750;
      _selectedLng = 75.3240;
      _isLocating = false;
    });
  }

  Future<void> _loadDirectory() async {
    setState(() {
      _isLoadingDirectory = true;
      _directoryError = null;
    });

    try {
      final list = await ApiClient.instance.fetchMissingPersons();
      setState(() {
        _cases = list;
        _isLoadingDirectory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDirectory = false;
        _directoryError = 'Could not load missing persons ($e)';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image: $e')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture last seen location.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final age = int.tryParse(_ageController.text.trim());
    final result = await ApiClient.instance.createMissingPerson(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      age: age,
      gender: _selectedGender,
      description: _descriptionController.text.trim(),
      latitude: _selectedLat!,
      longitude: _selectedLng!,
      isMinor: _isMinor,
      additionalInfo: _additionalInfoController.text.trim().isNotEmpty
          ? _additionalInfoController.text.trim()
          : null,
      photoUrl: _selectedImage?.name,
    );

    setState(() => _isSubmitting = false);

    if (result.isSuccess && mounted) {
      // Clear form
      _nameController.clear();
      _ageController.clear();
      _descriptionController.clear();
      _additionalInfoController.clear();
      setState(() {
        _selectedGender = null;
        _isMinor = false;
        _selectedImage = null;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
              SizedBox(width: 10),
              Text('Report Filed', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Missing person report successfully stored.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Case ID:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      result.caseId ?? 'MP-XXXX',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (result.alertCreated) ...[
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: Color(0xFFC62828), size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'High-priority operational alert generated for missing minor.',
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
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _tabController.animateTo(1);
                _loadDirectory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('VIEW IN DIRECTORY'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to submit report. Please retry.'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Missing Persons'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.person_add_alt_1_rounded), text: 'Report Case'),
            Tab(icon: Icon(Icons.person_search_rounded), text: 'Directory'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportForm(),
          _buildDirectoryView(),
        ],
      ),
    );
  }

  Widget _buildReportForm() {
    final pos = LatLng(_selectedLat ?? 17.6750, _selectedLng ?? 75.3240);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFFE65100), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Report lost warkaris or missing family members for quick volunteer dispatch.',
                      style: TextStyle(
                        color: Color(0xFFBF360C),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Person is a minor Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isMinor ? const Color(0xFFFFEBEE) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isMinor ? const Color(0xFFEF9A9A) : AppColors.border,
                  width: _isMinor ? 1.5 : 1.0,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Person is a Minor Child (Under 18)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _isMinor ? const Color(0xFFC62828) : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                subtitle: _isMinor
                    ? const Text(
                        '⚠️ Triggers immediate high-priority alert across volunteer network.',
                        style: TextStyle(color: Color(0xFFC62828), fontSize: 11),
                      )
                    : const Text(
                        'Check if the missing person is a child',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                value: _isMinor,
                activeTrackColor: const Color(0xFFEF9A9A),
                activeThumbColor: const Color(0xFFC62828),
                onChanged: (val) {
                  setState(() {
                    _isMinor = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name (Optional if unknown)',
                hintText: 'e.g. Aarav Shinde',
                prefixIcon: Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Age and Gender Row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g. 8',
                      prefixIcon: Icon(Icons.cake_outlined),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description Field (Required)
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              validator: (val) => val == null || val.trim().length < 3
                  ? 'Please describe clothes, appearance, and circumstances'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Description & Appearance *',
                hintText: 'e.g. Wearing yellow kurta, white topi, carrying water bottle. Separated near food tent.',
                prefixIcon: Icon(Icons.description_outlined),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Additional Info
            TextFormField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                labelText: 'Additional Info / Contact (Optional)',
                hintText: 'e.g. Dindi #4 pramukh phone: 9876543210',
                prefixIcon: Icon(Icons.contact_phone_outlined),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            // Photo Attachment Section (Optional)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _selectedImage == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Photo (Optional)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Attach a photo to help field Sevaks identify the person faster.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                label: const Text('CAMERA', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_outlined, size: 16),
                                label: const Text('GALLERY', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.secondary,
                                  side: const BorderSide(color: AppColors.secondary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImage!.path),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Photo Attached',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedImage!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Color(0xFFC62828)),
                          tooltip: 'Remove Photo',
                          onPressed: () => setState(() => _selectedImage = null),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Location Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last Seen Location *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                TextButton.icon(
                  onPressed: _isLocating ? null : _setCurrentLocationDefault,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 16),
                  label: const Text('USE CURRENT LOCATION'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Mini Map preview
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _miniMapController,
                  options: MapOptions(
                    initialCenter: pos,
                    initialZoom: 15.0,
                    onTap: (tapPos, latLng) {
                      setState(() {
                        _selectedLat = latLng.latitude;
                        _selectedLng = latLng.longitude;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sevakconnect.sevak_connect',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pos,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFC62828),
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedLat != null && _selectedLng != null) ...[
              const SizedBox(height: 4),
              Text(
                'Coordinates: ${_selectedLat!.toStringAsFixed(5)}, ${_selectedLng!.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting ? 'REPORTING...' : 'REPORT MISSING PERSON',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryView() {
    if (_isLoadingDirectory) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_directoryError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(_directoryError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadDirectory,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredList = _cases.where((c) {
      if (_selectedFilter == 'Open') return c.status == LostFoundStatus.open;
      if (_selectedFilter == 'Minors') return c.isMinor;
      if (_selectedFilter == 'Found') return c.status == LostFoundStatus.resolved;
      return true;
    }).toList();

    return Column(
      children: [
        // Filter Chips
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: ['All', 'Open', 'Minors', 'Found'].map((f) {
              final isSelected = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(f),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = f),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.background,
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),

        // List
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadDirectory,
            child: filteredList.isEmpty
                ? const Center(
                    child: Text('No missing persons reported in this category.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildCaseCard(item);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaseCard(LostFoundCase item) {
    final statusColor = item.status == LostFoundStatus.resolved
        ? const Color(0xFF2E7D32)
        : (item.status == LostFoundStatus.investigating
            ? const Color(0xFFF57F17)
            : const Color(0xFFC62828));

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: item.isMinor ? const Color(0xFFFFCDD2) : AppColors.border,
          width: item.isMinor ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Case ID + Minor badge + Status badge
            Row(
              children: [
                Text(
                  item.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                if (item.isMinor) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFEF9A9A)),
                    ),
                    child: const Text(
                      'MINOR',
                      style: TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF90CAF9)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_camera_outlined, size: 11, color: Color(0xFF1976D2)),
                        SizedBox(width: 3),
                        Text(
                          'PHOTO',
                          style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withAlpha(120)),
                  ),
                  child: Text(
                    item.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Name & Age
            Text(
              item.name != null && item.name!.isNotEmpty
                  ? item.name!
                  : 'Unidentified Person',
              style: AppTypography.headlineMd.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (item.age != null || (item.gender != null && item.gender!.isNotEmpty)) ...[
              const SizedBox(height: 2),
              Text(
                '${item.gender ?? ''}${item.age != null ? ', ${item.age} yrs' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 6),

            // Description
            Text(
              item.description,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF37474F)),
            ),

            if (item.additionalInfo != null && item.additionalInfo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Note: ${item.additionalInfo!}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                if (item.latitude != null && item.longitude != null) ...[
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
                const Spacer(),
                Text(
                  _formatTimeAgo(item.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
