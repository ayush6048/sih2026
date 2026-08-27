import 'package:flutter/material.dart';
import '../opportunities_screen.dart';
import '../recommendations_screen.dart';
import '../../services/api_service.dart';

class FindWorkTab extends StatelessWidget {
  final UserProfile profile;
  
  const FindWorkTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.business_center), text: 'Opportunities'),
                Tab(icon: Icon(Icons.star), text: 'Work Suggestions'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const OpportunitiesScreen(),
                RecommendationsScreen(recommendations: const []), // Temporary empty list until we refactor this
              ],
            ),
          ),
        ],
      ),
    );
  }
}
