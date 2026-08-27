import 'package:flutter/material.dart';
import '../profile_screen.dart';
import '../skill_analysis_screen.dart';
import '../../services/api_service.dart';

class MyProfileTab extends StatelessWidget {
  final UserProfile profile;
  
  const MyProfileTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.person), text: 'Your Information'),
                      Tab(icon: Icon(Icons.analytics), text: 'Skills to Learn'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IconButton(
                    icon: Icon(Icons.language, color: theme.colorScheme.primary),
                    tooltip: 'Change Language',
                    onPressed: () {
                      _showLanguageSelectionDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ProfileScreen(profile: profile),
                SkillAnalysisScreen(profile: profile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to English')));
                },
              ),
              ListTile(
                title: const Text('తెలుగు (Telugu)'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to తెలుగు')));
                },
              ),
              ListTile(
                title: const Text('हिंदी (Hindi)'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to हिंदी')));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
