import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  const OpportunityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return AppScaffold(
      title: 'Opportunity Details',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Agricultural Equipment Technician',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '91% Match',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoBadge(theme, Icons.work, 'Type', 'Employment'),
                const SizedBox(width: 32),
                _buildInfoBadge(theme, Icons.location_on, 'Location', 'Visakhapatnam'),
              ],
            ),
            const SizedBox(height: 64),
            
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(theme, 'WHY IT MATCHES YOU', Icons.thumb_up),
                        const SizedBox(height: 16),
                        _buildCheckmarkList(theme, [
                          'Matches your interest in machine repair',
                          'Uses your farming experience',
                          'Builds on your existing skills',
                          'Matches your career goal',
                        ]),
                        const SizedBox(height: 48),
                        _buildSectionHeader(theme, 'REQUIRED SKILLS', Icons.build),
                        const SizedBox(height: 16),
                        _buildBulletList(theme, [
                          'Equipment maintenance',
                          'Basic electrical',
                          'Machine diagnostics',
                        ]),
                        const SizedBox(height: 48),
                        _buildSectionHeader(theme, 'SKILLS YOU NEED TO IMPROVE', Icons.trending_up),
                        const SizedBox(height: 16),
                        _buildBulletList(theme, [
                          'Electrical basics',
                          'Equipment diagnostics',
                        ], icon: Icons.warning_amber_rounded, iconColor: Colors.orange.shade800),
                      ],
                    ),
                  ),
                  const SizedBox(width: 64),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(theme, 'CAREER PATH', Icons.timeline),
                        const SizedBox(height: 24),
                        _buildCareerPath(theme),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, 'WHY IT MATCHES YOU', Icons.thumb_up),
                  const SizedBox(height: 16),
                  _buildCheckmarkList(theme, [
                    'Matches your interest in machine repair',
                    'Uses your farming experience',
                    'Builds on your existing skills',
                    'Matches your career goal',
                  ]),
                  const SizedBox(height: 48),
                  _buildSectionHeader(theme, 'REQUIRED SKILLS', Icons.build),
                  const SizedBox(height: 16),
                  _buildBulletList(theme, [
                    'Equipment maintenance',
                    'Basic electrical',
                    'Machine diagnostics',
                  ]),
                  const SizedBox(height: 48),
                  _buildSectionHeader(theme, 'SKILLS YOU NEED TO IMPROVE', Icons.trending_up),
                  const SizedBox(height: 16),
                  _buildBulletList(theme, [
                    'Electrical basics',
                    'Equipment diagnostics',
                  ], icon: Icons.warning_amber_rounded, iconColor: Colors.orange.shade800),
                  const SizedBox(height: 48),
                  _buildSectionHeader(theme, 'CAREER PATH', Icons.timeline),
                  const SizedBox(height: 24),
                  _buildCareerPath(theme),
                ],
              ),
            
            const SizedBox(height: 64),
            Center(
              child: SizedBox(
                width: isDesktop ? 400 : double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opportunity saved to your profile!')),
                          );
                        },
                        child: const Text('Save Opportunity'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Back to Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildCheckmarkList(ThemeData theme, List<String> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(item, style: theme.textTheme.bodyLarge)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildBulletList(ThemeData theme, List<String> items, {IconData icon = Icons.fiber_manual_record, Color? iconColor}) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(icon, size: icon == Icons.fiber_manual_record ? 12 : 24, color: iconColor ?? Colors.grey.shade800),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(item, style: theme.textTheme.bodyLarge)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildCareerPath(ThemeData theme) {
    final steps = [
      'Current Experience',
      'Recommended Training',
      'Skill Development',
      'Agricultural Equipment Technician',
      'Employment'
    ];

    return Column(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 == 1) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Icon(Icons.arrow_downward, color: Colors.grey),
          );
        }
        final stepIndex = index ~/ 2;
        final step = steps[stepIndex];
        final isLast = stepIndex == steps.length - 1;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLast ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
            border: Border.all(color: isLast ? theme.colorScheme.primary : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            step,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isLast ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
            ),
          ),
        );
      }),
    );
  }
}
