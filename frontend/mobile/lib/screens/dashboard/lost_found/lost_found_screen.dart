import 'package:flutter/material.dart';
import '../../../widgets/app_data_table.dart';
import '../../../widgets/section_header.dart';

class LostFoundScreen extends StatelessWidget {
  const LostFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SectionHeader(
            title: 'Lost & Found Emergency Escalation',
            subtitle:
                'Prioritized child and elderly missing person tracking with expanding search perimeters and broadcast alerts.',
            icon: Icons.person_search_rounded,
          ),

          SizedBox(height: 20),

          // Cases Table / List Container
          AppDataTable(
            columns: [
              TableColumnDef(title: 'Name', flex: 3),
              TableColumnDef(title: 'Age', flex: 1),
              TableColumnDef(title: 'Last Seen Location', flex: 3),
              TableColumnDef(title: 'Time Reported', flex: 2),
              TableColumnDef(title: 'Status', flex: 2),
              TableColumnDef(title: 'Search Radius', flex: 2),
              TableColumnDef(title: 'Urgency', flex: 2),
              TableColumnDef(title: 'Actions', flex: 2),
            ],
            emptyTitle: 'No lost & found cases',
            emptyMessage:
                'Active missing person reports, photo identification matches, and search radius escalations (1km -> 2km -> 5km) will display here when filed.',
            emptyIcon: Icons.person_search_outlined,
          ),
        ],
      ),
    );
  }
}
