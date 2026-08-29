import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_theme.dart';
import 'empty_state.dart';

class TableColumnDef {
  final String title;
  final int flex;
  final TextAlign align;

  const TableColumnDef({
    required this.title,
    this.flex = 1,
    this.align = TextAlign.left,
  });
}

class AppDataTable extends StatelessWidget {
  final List<TableColumnDef> columns;
  final List<Widget> rows;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;

  const AppDataTable({
    super.key,
    required this.columns,
    this.rows = const [],
    this.emptyTitle = 'No data available',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Text(
                    col.title.toUpperCase(),
                    textAlign: col.align,
                    style: AppTypography.labelSm(
                      color: AppColors.onSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Body: Rows or Empty State
          if (rows.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.surfaceContainerHigh,
              ),
              itemBuilder: (context, idx) => rows[idx],
            )
          else
            EmptyState(
              title: emptyTitle,
              message: emptyMessage,
              icon: emptyIcon,
              verticalPadding: 64,
            ),
        ],
      ),
    );
  }
}
