import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/misc.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});
  final String kind; // 'privacy' | 'terms'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrivacy = kind == 'privacy';
    final title = isPrivacy ? 'Privacy Policy' : 'Terms & Conditions';
    final sections = isPrivacy
        ? const [
      ('Data we collect', 'WorkPulse stores your employment profile, attendance records, leave requests and payment history. This information is provided by your employer and is used solely to operate the employee self-service experience.'),
      ('How your data is used', 'Your data is displayed to you only. HR and payroll administrators access the same records through the company CRM to administer employment, leave and payroll. WorkPulse never sells or shares your data with third parties.'),
      ('Security', 'All communication between the app and company systems is encrypted in transit. Sessions expire automatically, and authentication credentials are never stored on the device in plain text.'),
      ('Your rights', 'You may request a copy or correction of your personal data at any time by contacting the People Operations team. Statutory payroll records are retained for the period required by law.'),
    ]
        : const [
      ('Acceptable use', 'WorkPulse is provided to active employees of Softzen Technologies Ltd for viewing personal employment information and submitting attendance and leave actions. Access is personal and must not be shared.'),
      ('Attendance & leave', 'Check-in and check-out timestamps recorded in the app are treated as official attendance data. Leave requests are subject to approval by HR in line with company policy.'),
      ('Payments', 'Payment figures shown in the app are informational. The payslip issued by payroll remains the authoritative record of your compensation.'),
      ('Availability', 'The service may be temporarily unavailable during maintenance windows. Continued use of the app constitutes acceptance of these terms as updated from time to time.'),
    ];

    return AppScaffold(
      title: title,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Reveal(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.grayBg, borderRadius: BorderRadius.circular(14)),
              child: Text(
                'Last updated: 1 July 2026 · Softzen Technologies Ltd',
                style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(sections.length, (i) {
            final (heading, body) = sections[i];
            return Reveal(
              delay: Duration(milliseconds: 60 + i * 60),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(heading, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6)),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}