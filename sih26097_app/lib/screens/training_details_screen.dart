import 'package:flutter/material.dart';
import 'opportunities_screen.dart';
import '../services/api_service.dart';
import '../widgets/app_scaffold.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final String trainingId;
  
  const TrainingDetailsScreen({super.key, required this.trainingId});

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  TrainingDetails? _trainingDetails;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _apiService.getTrainingDetails(widget.trainingId);
      if (mounted) {
        setState(() {
          _trainingDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppScaffold(
      title: 'Training Details',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildContent(context, theme),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    if (_trainingDetails == null) return const SizedBox.shrink();

    final isDesktop = MediaQuery.of(context).size.width > 800;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _trainingDetails!.title,
          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          _trainingDetails!.description,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );

    final skillsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'SKILLS YOU WILL DEVELOP', Icons.psychology),
        const SizedBox(height: 16),
        _buildBulletList(theme, _trainingDetails!.skillsDeveloped.isNotEmpty ? _trainingDetails!.skillsDeveloped : ["General skills"]),
      ],
    );

    final detailsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'COURSE DURATION', Icons.timer),
        const SizedBox(height: 16),
        Text(_trainingDetails!.duration, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        _buildSectionHeader(theme, 'NSQF ALIGNMENT', Icons.verified),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NSQF-aligned training pathway', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                _trainingDetails!.nsqfLevel,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ],
    );

    final actionButton = Center(
      child: SizedBox(
        width: isDesktop ? 400 : double.infinity,
        child: FilledButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OpportunitiesScreen()));
          },
          child: const Text('Find Opportunities'),
        ),
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 64.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 48),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: skillsSection),
                const SizedBox(width: 48),
                Expanded(child: detailsSection),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                skillsSection,
                const SizedBox(height: 40),
                detailsSection,
              ],
            ),
          const SizedBox(height: 64),
          actionButton,
        ],
      ),
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

  Widget _buildBulletList(ThemeData theme, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(item, style: theme.textTheme.bodyLarge)),
          ],
        ),
      )).toList(),
    );
  }
}
