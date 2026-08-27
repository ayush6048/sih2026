import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import 'dashboard/dashboard_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'icon': Icons.language},
    {'name': 'తెలుగు', 'icon': Icons.record_voice_over},
    {'name': 'हिंदी', 'icon': Icons.chat_bubble_outline},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return AppScaffold(
      title: 'Language / भाषा',
      maxWidth: isDesktop ? 1000 : 600,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 64.0 : 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose Your Language',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select the language you are most comfortable speaking.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                
                if (isDesktop)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _languages.map((lang) {
                      final languageName = lang['name'] as String;
                      final isSelected = _selectedLanguage == languageName;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildLanguageCard(
                            theme: theme,
                            language: languageName,
                            icon: lang['icon'] as IconData,
                            isSelected: isSelected,
                            isDesktop: true,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  Column(
                    children: _languages.map((lang) {
                      final languageName = lang['name'] as String;
                      final isSelected = _selectedLanguage == languageName;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildLanguageCard(
                          theme: theme,
                          language: languageName,
                          icon: lang['icon'] as IconData,
                          isSelected: isSelected,
                          isDesktop: false,
                        ),
                      );
                    }).toList(),
                  ),
                  
                const SizedBox(height: 64),
                Center(
                  child: SizedBox(
                    width: isDesktop ? 400 : double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required ThemeData theme,
    required String language,
    required IconData icon,
    required bool isSelected,
    required bool isDesktop,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 24, 
          vertical: isDesktop ? 48 : 24
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withAlpha(80) 
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(40),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: isDesktop
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade500,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    language,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade400,
                    size: 32,
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary.withAlpha(30) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: isSelected ? theme.colorScheme.primary : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      language,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade400,
                    size: 32,
                  ),
                ],
              ),
      ),
    );
  }
}
