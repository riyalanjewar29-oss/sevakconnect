import 'package:flutter/material.dart';
import '../../../widgets/app_data_table.dart';
import '../../../widgets/section_header.dart';

class HaltReadinessScreen extends StatelessWidget {
  const HaltReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SectionHeader(
            title: 'Halt Readiness & Pilgrimage Progress',
            subtitle:
                'Sequential monitoring of Wari halts, expected devotee influx, and resource fulfillment status.',
            icon: Icons.flag_circle_rounded,
          ),

          SizedBox(height: 20),

          // Halts Table Container
          AppDataTable(
            columns: [
              TableColumnDef(title: 'Seq', flex: 1),
              TableColumnDef(title: 'Halt Name', flex: 3),
              TableColumnDef(title: 'Status', flex: 2),
              TableColumnDef(title: 'ETA', flex: 2),
              TableColumnDef(title: 'Expected Crowd', flex: 2),
              TableColumnDef(title: 'Food / Meals', flex: 2),
              TableColumnDef(title: 'Water', flex: 2),
              TableColumnDef(title: 'Medical', flex: 2),
              TableColumnDef(title: 'Readiness', flex: 2),
            ],
            emptyTitle: 'No halt data available',
            emptyMessage:
                'Sequential halt milestones, resource fulfillment ratios, and coordinator telemetry will appear here when route data is synchronized.',
            emptyIcon: Icons.flag_outlined,
          ),
        ],
      ),
    );
  }
}
