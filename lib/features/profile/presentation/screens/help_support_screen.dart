import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    ('How do I check in and check out?',
    'Open the Home tab and tap the CHECK IN button when your shift starts. Tap CHECK OUT when you finish — you will be asked to confirm before the day is closed.'),
    ('How long does leave approval take?',
    'Leave requests are reviewed by the HR team, usually within 2 business days. You will receive a notification as soon as a decision is made.'),
    ('When are payments processed?',
    'Salaries are paid on the 25th of each month. If the 25th falls on a weekend or holiday, payments are processed on the previous business day.'),
    ('Who do I contact about a payroll issue?',
    'Reach out to People Operations at ${AppConstants.supportEmail} with your employee ID and the payment month in question.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Help & Support',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Reveal(
            child: AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(color: AppColors.infoBg, shape: BoxShape.circle),
                    child: const Icon(Icons.support_agent, size: 28, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text('Need a hand?', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Browse common questions or get in touch with the People Operations team.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Frequently Asked'),
          ...List.generate(_faqs.length, (i) {
            final (q, a) = _faqs[i];
            return Reveal(
              delay: Duration(milliseconds: i * 60),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    title: Text(q, style: theme.textTheme.titleSmall),
                    children: [Text(a, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.55))],
                  ),
                ),
              ),
            );
          }),
          const SectionHeader(title: 'Contact'),
          const Reveal(
            delay: Duration(milliseconds: 220),
            child: AppCard(
              child: Column(
                children: [
                  InfoRow(label: 'Email', value: AppConstants.supportEmail, icon: Icons.email_outlined),
                  Divider(height: 18),
                  InfoRow(label: 'Phone', value: AppConstants.supportPhone, icon: Icons.phone_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}