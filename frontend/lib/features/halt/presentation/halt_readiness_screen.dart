import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/halt_readiness.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

class HaltReadinessScreen extends StatefulWidget {
  const HaltReadinessScreen({super.key});

  @override
  State<HaltReadinessScreen> createState() => _HaltReadinessScreenState();
}

class _HaltReadinessScreenState extends State<HaltReadinessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();

  List<HaltReadiness> _halts = [];
  HaltReadiness? _selectedHalt;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHalts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHalts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiClient.instance.fetchHalts();
      if (!mounted) return;
      setState(() {
        _halts = list;
        if (_halts.isNotEmpty) {
          final currentId = _selectedHalt?.id;
          _selectedHalt = _halts.firstWhere(
            (h) => h.id == currentId,
            orElse: () => _halts.firstWhere(
              (h) => h.name.toLowerCase().contains('wakhari'),
              orElse: () => _halts.first,
            ),
          );
        } else {
          _selectedHalt = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load halt readiness.';
      });
    }
  }

  Future<void> _updateCategoryStatus({
    required HaltReadiness halt,
    required String category,
    required ItemStatus status,
  }) async {
    final prevHalt = halt;
    final exp = halt.expectedVarkaris;

    int water = halt.waterCapacityLiters;
    int food = halt.foodPacketsAvailable;
    int sanitation = halt.sanitationFacilities;
    int medical = halt.medicalTeams;
    int marshals = halt.crowdMarshals;

    if (category == 'water') {
      final target = exp * 3;
      water = status == ItemStatus.ready
          ? target
          : (status == ItemStatus.limited ? (target * 0.5).round() : (target * 0.1).round());
    } else if (category == 'food') {
      final target = exp;
      food = status == ItemStatus.ready
          ? target
          : (status == ItemStatus.limited ? (target * 0.5).round() : (target * 0.1).round());
    } else if (category == 'sanitation') {
      final target = (exp / 100).ceil();
      sanitation = status == ItemStatus.ready
          ? target
          : (status == ItemStatus.limited ? (target * 0.5).round() : 0);
    } else if (category == 'medical') {
      final target = (exp / 2000).ceil();
      medical = status == ItemStatus.ready
          ? target
          : (status == ItemStatus.limited ? 1 : 0);
    } else if (category == 'security') {
      final target = (exp / 250).ceil();
      marshals = status == ItemStatus.ready
          ? target
          : (status == ItemStatus.limited ? (target * 0.5).round() : 0);
    }

    final newScore = HaltReadiness.computeReadinessScore(
      expectedVarkaris: exp,
      waterLiters: water,
      foodPackets: food,
      toilets: sanitation,
      medicalStaff: medical,
      marshals: marshals,
    );
    final newLevel = ReadinessLevelExtension.fromScore(newScore);
    final newDeficits = HaltReadiness.detectDeficits(
      expectedVarkaris: exp,
      waterLiters: water,
      foodPackets: food,
      toilets: sanitation,
      medicalStaff: medical,
      marshals: marshals,
    );

    final optimisticHalt = halt.copyWith(
      waterCapacityLiters: water,
      foodPacketsAvailable: food,
      sanitationFacilities: sanitation,
      medicalTeams: medical,
      crowdMarshals: marshals,
      readinessScore: newScore,
      readinessLevel: newLevel,
      flaggedDeficits: newDeficits,
      lastUpdated: DateTime.now(),
    );

    setState(() {
      final idx = _halts.indexWhere((h) => h.id == halt.id);
      if (idx != -1) {
        _halts[idx] = optimisticHalt;
      }
      if (_selectedHalt?.id == halt.id) {
        _selectedHalt = optimisticHalt;
      }
    });

    try {
      final updated = await ApiClient.instance.updateHaltReadiness(
        halt.id,
        waterLiters: water,
        foodPackets: food,
        toilets: sanitation,
        medicalTeams: medical,
        crowdMarshals: marshals,
      );

      if (!mounted) return;

      if (updated != null) {
        setState(() {
          final idx = _halts.indexWhere((h) => h.id == halt.id);
          if (idx != -1) {
            _halts[idx] = updated;
          }
          if (_selectedHalt?.id == halt.id) {
            _selectedHalt = updated;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${halt.name} readiness saved: ${updated.readinessScore.toStringAsFixed(0)}% (${updated.readinessLevel.displayName})'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          final idx = _halts.indexWhere((h) => h.id == halt.id);
          if (idx != -1) {
            _halts[idx] = prevHalt;
          }
          if (_selectedHalt?.id == halt.id) {
            _selectedHalt = prevHalt;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update readiness. Please try again.'),
            backgroundColor: Color(0xFFC62828),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final idx = _halts.indexWhere((h) => h.id == halt.id);
        if (idx != -1) {
          _halts[idx] = prevHalt;
        }
        if (_selectedHalt?.id == halt.id) {
          _selectedHalt = prevHalt;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update readiness. Please try again.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    }
  }

  void _showUpdateModal(HaltReadiness halt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UPDATE READINESS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          halt.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select status for each checklist facility:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildModalCategoryRow(
                icon: '💧',
                title: 'Drinking Water',
                currentStatus: halt.waterStatus,
                onChanged: (newStatus) {
                  Navigator.pop(context);
                  _updateCategoryStatus(halt: halt, category: 'water', status: newStatus);
                },
              ),
              _buildModalCategoryRow(
                icon: '🍱',
                title: 'Food Distribution',
                currentStatus: halt.foodStatus,
                onChanged: (newStatus) {
                  Navigator.pop(context);
                  _updateCategoryStatus(halt: halt, category: 'food', status: newStatus);
                },
              ),
              _buildModalCategoryRow(
                icon: '🏥',
                title: 'Medical Station',
                currentStatus: halt.medicalStatus,
                onChanged: (newStatus) {
                  Navigator.pop(context);
                  _updateCategoryStatus(halt: halt, category: 'medical', status: newStatus);
                },
              ),
              _buildModalCategoryRow(
                icon: '🚻',
                title: 'Sanitation',
                currentStatus: halt.sanitationStatus,
                onChanged: (newStatus) {
                  Navigator.pop(context);
                  _updateCategoryStatus(halt: halt, category: 'sanitation', status: newStatus);
                },
              ),
              _buildModalCategoryRow(
                icon: '🛡️',
                title: 'Security',
                currentStatus: halt.securityStatus,
                onChanged: (newStatus) {
                  Navigator.pop(context);
                  _updateCategoryStatus(halt: halt, category: 'security', status: newStatus);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalCategoryRow({
    required String icon,
    required String title,
    required ItemStatus currentStatus,
    required ValueChanged<ItemStatus> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          SegmentedButton<ItemStatus>(
            segments: const [
              ButtonSegment(
                value: ItemStatus.ready,
                label: Text('READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              ButtonSegment(
                value: ItemStatus.limited,
                label: Text('LIMITED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              ButtonSegment(
                value: ItemStatus.notReady,
                label: Text('NOT READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
            selected: {currentStatus},
            onSelectionChanged: (Set<ItemStatus> selection) {
              onChanged(selection.first);
            },
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Halt & Camp Readiness'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh',
            onPressed: _loadHalts,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.checklist_rounded), text: 'Readiness Checklist'),
            Tab(icon: Icon(Icons.map_outlined), text: 'Readiness Map'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildChecklistView(),
          _buildHaltsMapView(),
        ],
      ),
    );
  }

  Widget _buildChecklistView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadHalts,
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

    if (_halts.isEmpty || _selectedHalt == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.holiday_village_outlined, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('No halt camps available.', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadHalts,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    final halt = _selectedHalt!;
    final levelColor = halt.readinessLevel == ReadinessLevel.ready
        ? const Color(0xFF2E7D32)
        : (halt.readinessLevel == ReadinessLevel.moderate
            ? const Color(0xFFE65100)
            : const Color(0xFFC62828));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SELECT HALT SECTION
          const Text(
            'SELECT HALT',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: halt.id,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 28),
                items: _halts.map((h) {
                  return DropdownMenuItem<String>(
                    value: h.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          h.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (h.readinessLevel == ReadinessLevel.ready
                                    ? const Color(0xFF2E7D32)
                                    : (h.readinessLevel == ReadinessLevel.moderate
                                        ? const Color(0xFFE65100)
                                        : const Color(0xFFC62828)))
                                .withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${h.readinessScore.toStringAsFixed(0)}% • ${h.readinessLevel.displayName}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: h.readinessLevel == ReadinessLevel.ready
                                  ? const Color(0xFF2E7D32)
                                  : (h.readinessLevel == ReadinessLevel.moderate
                                      ? const Color(0xFFE65100)
                                      : const Color(0xFFC62828)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newId) {
                  if (newId != null) {
                    setState(() {
                      _selectedHalt = _halts.firstWhere((h) => h.id == newId);
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. READINESS SCORE CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'READINESS SCORE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${halt.readinessScore.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: levelColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: levelColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: levelColor.withAlpha(120)),
                              ),
                              child: Text(
                                halt.readinessLevel.displayName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: levelColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 26),
                      tooltip: 'Update Readiness',
                      onPressed: () => _showUpdateModal(halt),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (halt.readinessScore / 100.0).clamp(0.0, 1.0),
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${halt.expectedVarkaris} Varkaris',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_rounded, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'ETA: ${halt.expectedArrival}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. CHECKLIST SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FACILITIES CHECKLIST',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Tap to update',
                style: TextStyle(fontSize: 11, color: AppColors.primary.withAlpha(200), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildChecklistItemCard(
            halt: halt,
            icon: '💧',
            name: 'Drinking Water',
            status: halt.waterStatus,
            capacityText: '${halt.waterCapacityLiters}L / ${halt.expectedVarkaris * 3}L required',
            categoryKey: 'water',
          ),
          _buildChecklistItemCard(
            halt: halt,
            icon: '🍱',
            name: 'Food Distribution',
            status: halt.foodStatus,
            capacityText: '${halt.foodPacketsAvailable} / ${halt.expectedVarkaris} packets required',
            categoryKey: 'food',
          ),
          _buildChecklistItemCard(
            halt: halt,
            icon: '🏥',
            name: 'Medical Station',
            status: halt.medicalStatus,
            capacityText: '${halt.medicalTeams} / ${(halt.expectedVarkaris / 2000).ceil()} teams required',
            categoryKey: 'medical',
          ),
          _buildChecklistItemCard(
            halt: halt,
            icon: '🚻',
            name: 'Sanitation',
            status: halt.sanitationStatus,
            capacityText: '${halt.sanitationFacilities} / ${(halt.expectedVarkaris / 100).ceil()} toilets required',
            categoryKey: 'sanitation',
          ),
          _buildChecklistItemCard(
            halt: halt,
            icon: '🛡️',
            name: 'Security',
            status: halt.securityStatus,
            capacityText: '${halt.crowdMarshals} / ${(halt.expectedVarkaris / 250).ceil()} marshals deployed',
            categoryKey: 'security',
          ),

          if (halt.flaggedDeficits.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFE65100)),
                      SizedBox(width: 6),
                      Text(
                        'Identified Shortages & Deficits:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE65100)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...halt.flaggedDeficits.map(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Color(0xFFBF360C), fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              d,
                              style: const TextStyle(fontSize: 12, color: Color(0xFFBF360C), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 4. UPDATE READINESS BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showUpdateModal(halt),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('UPDATE READINESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChecklistItemCard({
    required HaltReadiness halt,
    required String icon,
    required String name,
    required ItemStatus status,
    required String capacityText,
    required String categoryKey,
  }) {
    final statusColor = status.color;
    final statusIcon = status == ItemStatus.ready
        ? Icons.check_circle_rounded
        : (status == ItemStatus.limited ? Icons.warning_amber_rounded : Icons.cancel_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withAlpha(120)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            capacityText,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        onTap: () {
          final nextStatus = status == ItemStatus.ready
              ? ItemStatus.limited
              : (status == ItemStatus.limited ? ItemStatus.notReady : ItemStatus.ready);
          _updateCategoryStatus(halt: halt, category: categoryKey, status: nextStatus);
        },
      ),
    );
  }

  Widget _buildHaltsMapView() {
    final center = _selectedHalt != null
        ? LatLng(_selectedHalt!.latitude, _selectedHalt!.longitude)
        : const LatLng(17.6775, 75.3278);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sevakconnect.sevak_connect',
            ),
            MarkerLayer(
              markers: _halts.map((halt) {
                final isSelected = _selectedHalt?.id == halt.id;
                final levelColor = halt.readinessLevel == ReadinessLevel.ready
                    ? const Color(0xFF2E7D32)
                    : (halt.readinessLevel == ReadinessLevel.moderate
                        ? const Color(0xFFE65100)
                        : const Color(0xFFC62828));

                return Marker(
                  point: LatLng(halt.latitude, halt.longitude),
                  width: isSelected ? 56 : 46,
                  height: isSelected ? 56 : 46,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHalt = halt;
                      });
                      _mapController.move(
                        LatLng(halt.latitude, halt.longitude),
                        14.0,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: levelColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: isSelected ? 3.5 : 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${halt.readinessScore.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        if (_selectedHalt != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedHalt!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${_selectedHalt!.dindiName} • ${_selectedHalt!.expectedVarkaris} varkaris',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('CHECKLIST'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
