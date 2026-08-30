import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/models/app_task.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<AppTask> _allTasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  List<AppTask> get _displayTasks {
    if (_selectedFilter.toLowerCase() == 'all') {
      return _allTasks;
    }
    final targetStatus = TaskStatusExtension.fromString(_selectedFilter);
    return _allTasks.where((t) => t.status == targetStatus).toList();
  }

  static final List<AppTask> _fallbackDemoTasks = [
    AppTask(
      id: 'TSK-MED-001',
      title: 'Check Medical Camp',
      description: 'Verify first aid kits, emergency stretcher, and doctor availability at Tent 2.',
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      assignedTo: 'Pandharpur Sevak',
      locationName: 'Wakhari Phata',
      latitude: 17.6830,
      longitude: 75.3190,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    AppTask(
      id: 'TSK-WTR-002',
      title: 'Verify Water Supply',
      description: 'Check 2000L water tanker pressure and refill status for incoming Dindi groups.',
      priority: TaskPriority.medium,
      status: TaskStatus.inProgress,
      assignedTo: 'Pandharpur Sevak',
      locationName: 'Malwadi Halt',
      latitude: 17.6745,
      longitude: 75.3210,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    AppTask(
      id: 'TSK-CRD-003',
      title: 'Crowd Checkpoint Support',
      description: 'Assist police volunteers at North Gate entry barricades during peak morning rush.',
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      assignedTo: 'Pandharpur Sevak',
      locationName: 'Pandharpur Entry',
      latitude: 17.6750,
      longitude: 75.3240,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppTask(
      id: 'TSK-SAN-004',
      title: 'Sanitation Check',
      description: 'Inspect mobile toilet cleanliness and waste disposal tanks at Sector 4.',
      priority: TaskPriority.low,
      status: TaskStatus.completed,
      assignedTo: 'Pandharpur Sevak',
      locationName: 'Pandharpur Entry',
      latitude: 17.6710,
      longitude: 75.3280,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _allTasks = _fallbackDemoTasks;
    _isLoading = false;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final list = await ApiClient.instance.fetchTasks();
      if (mounted && list.isNotEmpty) {
        setState(() {
          _allTasks = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(AppTask task, TaskStatus newStatus) async {
    final originalTasks = List<AppTask>.from(_allTasks);

    // Optimistic UI update
    setState(() {
      _allTasks = _allTasks.map((t) {
        if (t.id == task.id) {
          return t.copyWith(status: newStatus, updatedAt: DateTime.now());
        }
        return t;
      }).toList();
    });

    final updated = await ApiClient.instance.updateTaskStatus(
      task.id,
      newStatus.displayName,
    );

    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${task.title} marked as ${newStatus.displayName}'),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
      _loadTasks();
    } else if (mounted) {
      // Revert
      setState(() => _allTasks = originalTasks);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task status. Please retry.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    }
  }

  void _showMapModal(AppTask task) {
    if (task.position == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Container(
        height: 420,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTypography.headlineLg.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.locationName,
                        style: AppTypography.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: task.position!,
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
                          point: task.position!,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: task.priority.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.assignment, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes.clamp(1, 59)}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _allTasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgressCount = _allTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final completedCount = _allTasks.where((t) => t.status == TaskStatus.completed).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Tasks',
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Metrics Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.white,
            child: Row(
              children: [
                _buildMetricBox('Total', '${_allTasks.length}', AppColors.textPrimary, const Color(0xFFF5F5F5)),
                const SizedBox(width: 8),
                _buildMetricBox('In Progress', '$inProgressCount', const Color(0xFFE65100), const Color(0xFFFFF3E0)),
                const SizedBox(width: 8),
                _buildMetricBox('Pending', '$pendingCount', const Color(0xFF5D4037), const Color(0xFFEFEBE9)),
                const SizedBox(width: 8),
                _buildMetricBox('Completed', '$completedCount', const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Filter Segmented Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'In Progress', 'Completed'].map((filter) {
                  final isSelected = _selectedFilter.toLowerCase() == filter.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      backgroundColor: const Color(0xFFF9F7F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Main Task List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _displayTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.black26),
                            const SizedBox(height: 12),
                            Text(
                              'No ${_selectedFilter == "All" ? "" : _selectedFilter} tasks found',
                              style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        color: AppColors.primary,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                          children: _displayTasks.map((task) => _buildTaskCard(task)).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String count, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(AppTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.priority.containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${task.priority.displayName} PRIORITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: task.priority.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.status.containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: task.status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.locationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Updated: ${_formatTime(task.updatedAt)} • Assigned to ${task.assignedTo}',
            style: const TextStyle(color: Colors.black45, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (task.status == TaskStatus.pending)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(task, TaskStatus.inProgress),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('START TASK', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              else if (task.status == TaskStatus.inProgress)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(task, TaskStatus.completed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('COMPLETE TASK', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '✓ Task Completed',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              if (task.position != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showMapModal(task),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('MAP'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
