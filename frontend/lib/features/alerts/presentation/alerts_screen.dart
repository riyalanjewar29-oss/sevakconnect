import 'package:flutter/material.dart';
import '../../../core/models/app_alert.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<AppAlert> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Critical & High',
    'River Safety',
    'Crowd',
  ];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final alerts = await ApiClient.instance.fetchAlerts();
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load operational alerts ($e)';
      });
    }
  }

  Future<void> _markRead(AppAlert alert) async {
    if (alert.isRead) return;

    // Optimistic UI update
    setState(() {
      _alerts = _alerts.map((a) {
        if (a.id == alert.id) {
          return a.copyWith(isRead: true);
        }
        return a;
      }).toList();
    });

    final success = await ApiClient.instance.markAlertAsRead(alert.id);
    if (!success && mounted) {
      // Revert if failed
      _loadAlerts();
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFC62828);
      case 'HIGH':
        return const Color(0xFFE65100);
      case 'WARNING':
        return const Color(0xFFF57F17);
      case 'INFO':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'river_safety':
      case 'river':
        return Icons.waves_rounded;
      case 'crowd':
        return Icons.groups_rounded;
      case 'emergency':
      case 'medical':
        return Icons.local_hospital_rounded;
      case 'route':
        return Icons.alt_route_rounded;
      case 'supply':
        return Icons.inventory_2_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  List<AppAlert> get _filteredAlerts {
    switch (_selectedFilter) {
      case 'Unread':
        return _alerts.where((a) => !a.isRead).toList();
      case 'Critical & High':
        return _alerts.where((a) => a.isCritical || a.isHigh).toList();
      case 'River Safety':
        return _alerts.where((a) => a.type == 'river_safety').toList();
      case 'Crowd':
        return _alerts.where((a) => a.type == 'crowd').toList();
      case 'All':
      default:
        return _alerts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCritical = _alerts.where((a) => a.isCritical && !a.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Operational Alerts'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAlerts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading active alerts...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : Column(
                  children: [
                    // Filter Chips Bar
                    _buildFilterChips(),

                    // Alert List
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadAlerts,
                        child: _filteredAlerts.isEmpty
                            ? _buildEmptyView()
                            : ListView(
                                padding: const EdgeInsets.all(16.0),
                                children: [
                                  // Critical Alert Banner if unread critical alert exists
                                  if (unreadCritical.isNotEmpty && _selectedFilter == 'All')
                                    _buildCriticalAlertBanner(unreadCritical.first),

                                  ..._filteredAlerts.map((alert) => _buildAlertCard(alert)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
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
                backgroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCriticalAlertBanner(AppAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEF9A9A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC62828).withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFC62828),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'CRITICAL OPERATIONAL ALERT',
                style: TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(alert.createdAt),
                style: const TextStyle(
                  color: Color(0xFFC62828),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.title,
            style: AppTypography.headlineMd.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            alert.description,
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF5D4037),
              fontSize: 13,
            ),
          ),
          if (alert.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFC62828)),
                const SizedBox(width: 4),
                Text(
                  alert.location,
                  style: const TextStyle(
                    color: Color(0xFFC62828),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _markRead(alert),
                  child: const Text(
                    'ACKNOWLEDGE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertCard(AppAlert alert) {
    final sevColor = _getSeverityColor(alert.severity);
    final typeIcon = _getTypeIcon(alert.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: alert.isRead ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: alert.isRead ? AppColors.border : sevColor.withAlpha(120),
          width: alert.isRead ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: alert.isRead
                ? AppColors.secondary.withAlpha(6)
                : sevColor.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          onTap: () => _markRead(alert),
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Type icon + Severity badge + Time + Unread indicator
                Row(
                  children: [
                    Icon(typeIcon, color: sevColor, size: 18),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: sevColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert.severity,
                        style: TextStyle(
                          color: sevColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimeAgo(alert.createdAt),
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    if (!alert.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: sevColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  alert.title,
                  style: AppTypography.headlineMd.copyWith(
                    fontSize: 14,
                    fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  alert.description,
                  style: AppTypography.bodySm.copyWith(
                    color: alert.isRead
                        ? AppColors.textSecondary
                        : const Color(0xFF37474F),
                    fontSize: 12.5,
                  ),
                ),

                // Bottom location tag & action
                if (alert.location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        alert.location,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      if (!alert.isRead)
                        Text(
                          'Tap to mark read',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 56, color: AppColors.primary.withAlpha(120)),
          const SizedBox(height: 12),
          Text(
            'No ${_selectedFilter == 'All' ? '' : _selectedFilter} alerts',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All Wari corridors and river zones are operating normally.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
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
              _errorMessage ?? 'Failed to load operational alerts',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAlerts,
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
}
