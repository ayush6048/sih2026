import 'package:flutter/material.dart';
import 'skill_analysis_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    int filledFields = 0;
    if (profile.education != null) filledFields++;
    if (profile.occupation != null) filledFields++;
    if (profile.skills.isNotEmpty) filledFields++;
    if (profile.interests.isNotEmpty) filledFields++;
    if (profile.location != null) filledFields++;
    if (profile.careerGoal != null) filledFields++;
    final double progress = filledFields / 6.0;

    final profileSections = [
      _buildSection(theme, "Education", profile.education ?? "Not provided", Icons.school),
      _buildSection(theme, "Occupation", profile.occupation ?? "Not provided", Icons.work),
      _buildListSection(theme, "Skills", profile.skills.isNotEmpty ? profile.skills : ["Not provided"], Icons.build),
      _buildListSection(theme, "Interests", profile.interests.isNotEmpty ? profile.interests : ["Not provided"], Icons.favorite),
      _buildSection(theme, "Location", profile.location ?? "Not provided", Icons.location_on),
      _buildSection(theme, "Career Goal", profile.careerGoal ?? "Not provided", Icons.flag),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Livelihood Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: isDesktop ? 64 : 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: isDesktop ? 64 : 48, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  "Your Information",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "This is the information you have provided to us.",
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: isDesktop ? 400 : double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Your Information", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text("${(progress * 100).toInt()}%", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                        backgroundColor: theme.colorScheme.primaryContainer.withAlpha(100),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
            
            if (isDesktop)
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 32,
                  mainAxisSpacing: 32,
                  mainAxisExtent: 180,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profileSections.length,
                itemBuilder: (context, index) => profileSections[index],
              )
            else
              Column(
                children: profileSections.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: w,
                )).toList(),
              ),
            
            const SizedBox(height: 64),
            Center(
              child: SizedBox(
                width: isDesktop ? 400 : double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SkillAnalysisScreen(profile: profile)),
                    );
                  },
                  icon: const Icon(Icons.analytics, size: 28),
                  label: const Text("Skills to Learn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String value, IconData icon) {
    return _SectionCard(
      theme: theme,
      icon: icon,
      title: title,
      content: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildListSection(ThemeData theme, String title, List<String> items, IconData icon) {
    return _SectionCard(
      theme: theme,
      icon: icon,
      title: title,
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return Chip(
            label: Text(item),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.theme,
    required this.icon,
    required this.title,
    required this.content,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(150),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
