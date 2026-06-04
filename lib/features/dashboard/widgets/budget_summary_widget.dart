import 'package:flutter/material.dart';
import 'package:kap/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/database_service.dart';

class BudgetSummaryWidget extends StatelessWidget {
  const BudgetSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = context.watch<DatabaseService>();
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: dbService.getTumUrunler(),
      builder: (context, snapshot) {
        double totalSpending = 0.0;
        double pendingSpending = 0.0;

        if (snapshot.hasData && snapshot.data != null) {
          for (var item in snapshot.data!) {
            final alindiMi = item['alindiMi'] as bool? ?? false;
            final fiyat = item['fiyat'];
            double itemFiyat = 0.0;
            if (fiyat != null) {
              if (fiyat is num) {
                itemFiyat = fiyat.toDouble();
              } else if (fiyat is String) {
                itemFiyat = double.tryParse(fiyat) ?? 0.0;
              }
            }

            totalSpending += itemFiyat;
            if (!alindiMi) {
              pendingSpending += itemFiyat;
            }
          }
        }

        return Row(
          children: [
            // Left Card: Total Spending
            Expanded(
              child: _buildStatsCard(
                title: l10n.totalSpending,
                amount: totalSpending,
              ),
            ),
            const SizedBox(width: 16),
            // Right Card: Pending Spending
            Expanded(
              child: _buildStatsCard(
                title: l10n.pendingSpending,
                amount: pendingSpending,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard({required String title, required double amount}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: KapColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KapColors.borderLight,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₺${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: KapColors.primaryAccent, // Terracotta orange
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
