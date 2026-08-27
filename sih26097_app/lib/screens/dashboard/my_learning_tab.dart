import 'package:flutter/material.dart';
import '../my_courses_screen.dart';
import '../explore_courses_screen.dart';

class MyLearningTab extends StatelessWidget {
  const MyLearningTab({super.key});

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
                Tab(icon: Icon(Icons.book), text: 'My Courses'),
                Tab(icon: Icon(Icons.search), text: 'Explore Courses'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                MyCoursesScreen(),
                ExploreCoursesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
