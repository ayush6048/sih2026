import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final visual = Container(
      padding: EdgeInsets.all(isDesktop ? 48.0 : 32.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.mic_rounded,
        size: isDesktop ? 120 : 72,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );

    final contentBlocks = [
      Text(
        'Livelihood AI Assistant',
        textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Find the right skills, training and livelihood opportunities for you.',
        textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Talk to our AI assistant and discover a career path that matches your skills and interests.',
        textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    ];

    final actionBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Get Started'),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AI-powered livelihood guidance',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    return AppScaffold(
      title: 'Welcome',
      showBackButton: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(child: Center(child: visual)),
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...contentBlocks,
                          const SizedBox(height: 48),
                          actionBlock,
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const Spacer(),
                    visual,
                    const SizedBox(height: 48),
                    ...contentBlocks,
                    const Spacer(),
                    actionBlock,
                  ],
                ),
        ),
      ),
    );
  }
}
