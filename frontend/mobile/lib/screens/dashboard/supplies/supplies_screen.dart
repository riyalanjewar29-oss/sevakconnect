import 'package:flutter/material.dart';
import '../../../widgets/app_data_table.dart';
import '../../../widgets/section_header.dart';

class SuppliesScreen extends StatelessWidget {
  const SuppliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SectionHeader(
            title: 'Supply Inventory & Intelligent Redistribution',
            subtitle:
                'Monitor food packets, drinking water tankers, and medical supplies across halts with smart deficit balancing.',
            icon: Icons.inventory_2_rounded,
          ),

          SizedBox(height: 20),

          // Inventory Table Container
          AppDataTable(
            columns: [
              TableColumnDef(title: 'Halt / Camp Location', flex: 3),
              TableColumnDef(title: 'Meals Available', flex: 2),
              TableColumnDef(title: 'Water Available', flex: 2),
              TableColumnDef(title: 'Shortage / Deficit', flex: 2),
              TableColumnDef(title: 'Surplus', flex: 2),
              TableColumnDef(title: 'Redistribution Suggestion', flex: 3),
            ],
            emptyTitle: 'No supply data available',
            emptyMessage:
                'Camp inventory levels, shortage alarms, and automated nearby surplus redistribution recommendations will appear here as logistics coordinators report in.',
            emptyIcon: Icons.inventory_2_outlined,
          ),
        ],
      ),
    );
  }
}
