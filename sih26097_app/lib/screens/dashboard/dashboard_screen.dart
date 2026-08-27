import 'package:flutter/material.dart';
import '../voice_assistant_screen.dart';
import 'home_tab.dart';
import 'my_learning_tab.dart';
import 'find_work_tab.dart';
import 'my_profile_tab.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../welcome_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  // Dummy profile for now - in reality this would be fetched from backend or managed in state
  final UserProfile _userProfile = UserProfile();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    AuthService().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeTab(
          onNavigate: _onItemTapped,
          profile: _userProfile,
        );
      case 1:
        return VoiceAssistantScreen(onNavigate: _onItemTapped);
      case 2:
        return const MyLearningTab();
      case 3:
        return FindWorkTab(profile: _userProfile);
      case 4:
        return MyProfileTab(profile: _userProfile);
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final theme = Theme.of(context);

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.school, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Livelihood AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: MediaQuery.of(context).size.width > 1200 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              backgroundColor: theme.colorScheme.surface,
              extended: MediaQuery.of(context).size.width > 1200,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.mic), label: Text('Talk to AI')),
                NavigationRailDestination(icon: Icon(Icons.book), label: Text('My Learning')),
                NavigationRailDestination(icon: Icon(Icons.work), label: Text('Find Work')),
                NavigationRailDestination(icon: Icon(Icons.person), label: Text('My Profile')),
                NavigationRailDestination(icon: Icon(Icons.logout), label: Text('Logout')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _selectedIndex == 5 
                ? const Center(child: CircularProgressIndicator()) 
                : _buildBody(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livelihood Platform'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _selectedIndex == 5 ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Work'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
