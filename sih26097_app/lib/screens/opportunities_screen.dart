import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'opportunity_details_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Jobs', 'Self Employment', 'Nearby'];

  List<Opportunity> _opportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    final ops = await ApiService().getOpportunities();
    if (mounted) {
      setState(() {
        _opportunities = ops;
        _isLoading = false;
      });
    }
  }

  List<Opportunity> get _filteredOpportunities {
    if (_selectedFilter == 'All') return _opportunities;
    if (_selectedFilter == 'Jobs') {
      return _opportunities.where((o) => o.type.contains('Job')).toList();
    }
    if (_selectedFilter == 'Self Employment') {
      return _opportunities.where((o) => o.type.contains('Self Employment')).toList();
    }
    if (_selectedFilter == 'Nearby') {
      return _opportunities.where((o) => o.location.contains('Nearby') || o.location.contains('Local')).toList();
    }
    return _opportunities;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildProfileSummary(theme, isDesktop),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildFilters(theme),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : isDesktop
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    mainAxisExtent: 320,
                  ),
                  itemCount: _filteredOpportunities.length,
                  itemBuilder: (context, index) {
                    final opp = _filteredOpportunities[index];
                    return _buildOpportunityCard(context, opp, theme);
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: _filteredOpportunities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final opp = _filteredOpportunities[index];
                    return _buildOpportunityCard(context, opp, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileSummary(ThemeData theme, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isDesktop 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryRow(theme, Icons.location_on, 'Location:', 'Visakhapatnam'),
              _buildSummaryRow(theme, Icons.star, 'Recommended Skill:', 'Agricultural Equipment Technician'),
              _buildSummaryRow(theme, Icons.flag, 'Career Goal:', 'Find a job'),
            ],
          )
        : Column(
            children: [
              _buildSummaryRow(theme, Icons.location_on, 'Location:', 'Visakhapatnam'),
              const SizedBox(height: 12),
              _buildSummaryRow(theme, Icons.star, 'Recommended Skill:', 'Agricultural Equipment Technician'),
              const SizedBox(height: 12),
              _buildSummaryRow(theme, Icons.flag, 'Career Goal:', 'Find a job'),
            ],
          ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, Opportunity opp, ThemeData theme) {
    final title = opp.title;
    final match = '${opp.matchPercentage}%';
    final type = opp.type;
    final location = opp.location;
    final skills = opp.requiredSkills;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$match Match',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.work, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text('Type: ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Expanded(child: Text(type, style: theme.textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text('Location: ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Expanded(child: Text(location, style: theme.textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Skills:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: skills.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text(s, style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OpportunityDetailsScreen(),
                    ),
                  );
                },
                child: const Text('View Opportunity'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
