import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../halt/presentation/halt_readiness_screen.dart';

/// Screen for tracking and updating camp resource inventories across Wari halts.
class CampSuppliesScreen extends StatefulWidget {
  final String? initialHalt;

  const CampSuppliesScreen({super.key, this.initialHalt});

  @override
  State<CampSuppliesScreen> createState() => _CampSuppliesScreenState();
}

class _CampSuppliesScreenState extends State<CampSuppliesScreen> {
  String _selectedHalt = 'All Halts';
  bool _isLoading = false;
  String? _errorMessage;
  List<SupplyItemData> _supplies = [];

  final List<String> _haltOptions = [
    'All Halts',
    'Wakhari Phata',
    'Bhakti Marg Checkpoint',
    'Chandrabhaga River Ghat',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialHalt != null && _haltOptions.contains(widget.initialHalt)) {
      _selectedHalt = widget.initialHalt!;
    }
    _loadSupplies();
  }

  Future<void> _loadSupplies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiClient.instance.fetchSupplies(
        location: _selectedHalt == 'All Halts' ? null : _selectedHalt,
      );

      if (mounted) {
        setState(() {
          _supplies = items;
          _isLoading = false;
          if (items.isEmpty) {
            _errorMessage = 'No supply records found for $_selectedHalt.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load live supply data. Please try again.';
        });
      }
    }
  }

  IconData _getResourceIcon(String resource) {
    final r = resource.toLowerCase();
    if (r.contains('water')) return Icons.water_drop_rounded;
    if (r.contains('food') || r.contains('meal')) return Icons.restaurant_rounded;
    if (r.contains('med')) return Icons.medical_services_rounded;
    return Icons.inventory_2_rounded;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.statusNormal;
      case 'LOW':
        return AppColors.statusModerate;
      case 'CRITICAL':
        return AppColors.statusCritical;
      default:
        return AppColors.textSecondary;
    }
  }

  void _openUpdateModal([SupplyItemData? item]) {
    String selectedResource = item?.resource ?? 'water';
    String selectedLocation = item?.location ?? (_selectedHalt != 'All Halts' ? _selectedHalt : 'Wakhari Phata');
    final quantityController = TextEditingController(text: item != null ? item.quantity.toString() : '500');
    final reqQuantityController = TextEditingController(text: item != null ? item.requiredQuantity.toString() : '500');
    bool isSubmitting = false;
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Update Supply Inventory',
                          style: AppTypography.headlineMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          modalError!,
                          style: const TextStyle(fontSize: 12, color: AppColors.statusCritical, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Resource Selector
                    const Text('RESOURCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedResource,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'water', child: Text('💧 Drinking Water (Liters)')),
                            DropdownMenuItem(value: 'food', child: Text('🍱 Meals / Ration (Packets)')),
                            DropdownMenuItem(value: 'medical', child: Text('🩹 Medical Aid Kits (Kits)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedResource = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Location / Halt Selector
                    const Text('HALT / LOCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLocation,
                          isExpanded: true,
                          items: _haltOptions
                              .where((h) => h != 'All Halts')
                              .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedLocation = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Current vs Required Quantity
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CURRENT STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.background,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TARGET NEED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: reqQuantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.background,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final qty = int.tryParse(quantityController.text.trim());
                                final reqQty = int.tryParse(reqQuantityController.text.trim());
                                if (qty == null || reqQty == null || qty < 0 || reqQty <= 0) {
                                  setModalState(() => modalError = 'Please enter valid stock quantities.');
                                  return;
                                }

                                setModalState(() {
                                  isSubmitting = true;
                                  modalError = null;
                                });

                                final res = await ApiClient.instance.updateSupply(
                                  resource: selectedResource,
                                  quantity: qty,
                                  requiredQuantity: reqQty,
                                  location: selectedLocation,
                                );

                                if (res.isSuccess) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(res.message ?? 'Supply updated successfully!'),
                                        backgroundColor: AppColors.statusNormal,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    _loadSupplies();
                                  }
                                } else {
                                  setModalState(() {
                                    isSubmitting = false;
                                    modalError = res.errorMessage ?? 'Failed to update supply.';
                                  });
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save & Update Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
          'Camp Supplies',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rtl_rounded, color: AppColors.primary),
            tooltip: 'Halt Readiness',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HaltReadinessScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh supplies',
            onPressed: _loadSupplies,
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
            // Filter Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedHalt,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          items: _haltOptions
                              .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedHalt = val);
                              _loadSupplies();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null && _supplies.isEmpty)
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

            // Supplies List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSupplies,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _supplies.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _supplies[index];
                          return _buildSupplyCard(item);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text('UPDATE SUPPLY INVENTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
            onPressed: () => _openUpdateModal(),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplyCard(SupplyItemData item) {
    final statusColor = _getStatusColor(item.status);
    final icon = _getResourceIcon(item.resource);

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
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.resourceName,
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        item.location,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Text(
                  item.status,
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

          const SizedBox(height: 12),

          // Quantity Progress Bar & Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.quantity} ${item.unit} available',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: item.isCritical ? AppColors.statusCritical : AppColors.textPrimary,
                ),
              ),
              Text(
                'Need: ${item.requiredQuantity} ${item.unit}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.fulfillmentRatio,
              minHeight: 6,
              backgroundColor: AppColors.background,
              color: statusColor,
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _openUpdateModal(item),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit Stock',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
