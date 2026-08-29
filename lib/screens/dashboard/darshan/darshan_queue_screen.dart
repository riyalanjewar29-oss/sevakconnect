import 'package:flutter/material.dart';
import '../../../widgets/app_data_table.dart';
import '../../../widgets/section_header.dart';

class DarshanQueueScreen extends StatelessWidget {
  const DarshanQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SectionHeader(
            title: 'Darshan Queue Batch Coordination',
            subtitle:
                'Real-time Palkhi and Dindi batch token tracking, holding enclosure capacities, and queue progression.',
            icon: Icons.view_timeline_rounded,
          ),

          SizedBox(height: 20),

          // Dense Table Container
          AppDataTable(
            columns: [
              TableColumnDef(title: 'Dindi', flex: 3),
              TableColumnDef(title: 'Block', flex: 2),
              TableColumnDef(title: 'Batch', flex: 2),
              TableColumnDef(title: 'Token', flex: 2),
              TableColumnDef(title: 'Status', flex: 2),
              TableColumnDef(title: 'Estimated Time', flex: 2),
              TableColumnDef(title: 'Actions', flex: 2),
            ],
            emptyTitle: 'No Darshan queue data available',
            emptyMessage:
                'Darshan queue batches, token allocations, and enclosure movement timestamps will appear here when active batches are registered.',
            emptyIcon: Icons.view_timeline_outlined,
          ),
        ],
      ),
    );
  }
}
