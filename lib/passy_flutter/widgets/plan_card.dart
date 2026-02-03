import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/passy_cloud.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final bool highlight;
  final bool subscribed;
  final bool canceled;
  final VoidCallback onSelect;
  final VoidCallback onCancel;

  const PlanCard({
    super.key,
    required this.plan,
    this.highlight = false,
    this.subscribed = false,
    this.canceled = false,
    required this.onSelect,
    required this.onCancel,
  });

  String _localizeType() {
    switch (plan.plan) {
      case 'monthly':
        return localizations.monthly;
      case 'yearly':
        return localizations.yearly;
      case 'lifetime':
        return localizations.lifetime;
      default:
        return '';
    }
  }

  String _localizePrice(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.countryCode == 'GB') {
      return plan.prices.gbp;
    } else {
      return plan.prices.usd;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: highlight
            ? BorderSide(
                color: PassyTheme.of(context).highlightContentSecondaryColor,
                width: 5,
              )
            : BorderSide.none,
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${plan.service[0].toUpperCase()}${plan.service.substring(1)} ${_localizeType()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _localizePrice(context),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
              backgroundColor: canceled ? Colors.transparent : null,
              heroTag: null,
              onPressed: canceled
                  ? () {}
                  : subscribed
                      ? onCancel
                      : onSelect,
              label: Text(
                canceled
                    ? localizations.canceled
                    : subscribed
                        ? localizations.cancel
                        : localizations.selectPlan,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: subscribed ? Colors.red : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
