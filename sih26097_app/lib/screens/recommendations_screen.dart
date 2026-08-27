import 'package:flutter/material.dart';
import 'training_details_screen.dart';
import '../services/api_service.dart';

class RecommendationsScreen extends StatelessWidget {
  final List<CareerRecommendation> recommendations;

  const RecommendationsScreen({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return recommendations.isEmpty 
        ? const Center(child: Text("No work suggestions found for you yet."))
        : isDesktop
            ? GridView.builder(
                padding: const EdgeInsets.all(48.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 32,
                  mainAxisSpacing: 32,
                  childAspectRatio: 0.8, // Adjust as needed
                ),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return _buildRecommendationCard(
                    context,
                    rank: (index + 1).toString(),
                    title: rec.title,
                    matchPercentage: '${rec.matchPercentage}%',
                    matchLevel: rec.matchLevel,
                    isPrimary: index == 0,
                    whyRecommended: rec.whyRecommended.isNotEmpty ? rec.whyRecommended : ["Matches your profile"],
                    skillGapAddressed: rec.skillGapAddressed,
                    onDetailsPressed: () {
                      if (rec.trainingIds.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TrainingDetailsScreen(trainingId: rec.trainingIds.first)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No training available for this role yet.')));
                      }
                    },
                  );
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildRecommendationCard(
                      context,
                      rank: (index + 1).toString(),
                      title: rec.title,
                      matchPercentage: '${rec.matchPercentage}%',
                      matchLevel: rec.matchLevel,
                      isPrimary: index == 0,
                      whyRecommended: rec.whyRecommended.isNotEmpty ? rec.whyRecommended : ["Matches your profile"],
                      skillGapAddressed: rec.skillGapAddressed,
                      onDetailsPressed: () {
                        if (rec.trainingIds.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TrainingDetailsScreen(trainingId: rec.trainingIds.first)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No training available for this role yet.')));
                        }
                      },
                    ),
                  );
                },
              );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required String rank,
    required String title,
    required String matchPercentage,
    required String matchLevel,
    required bool isPrimary,
    required List<String> whyRecommended,
    required List<String> skillGapAddressed,
    required VoidCallback onDetailsPressed,
  }) {
    final theme = Theme.of(context);
    final bgColor = isPrimary ? theme.colorScheme.primaryContainer.withAlpha(80) : theme.colorScheme.surfaceContainerHighest.withAlpha(80);
    final borderColor = isPrimary ? theme.colorScheme.primary : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isPrimary ? 2 : 1),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isPrimary ? theme.colorScheme.primary : Colors.grey.shade500,
                foregroundColor: Colors.white,
                radius: 20,
                child: Text(rank, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$matchPercentage Good Match',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            matchLevel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why recommended:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...whyRecommended.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(detail, style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  )),
                  
                  if (skillGapAddressed.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Skills this job requires:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...skillGapAddressed.map((detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(child: Text(detail, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: isPrimary 
              ? FilledButton(
                  onPressed: onDetailsPressed,
                  child: const Text('View Details'),
                )
              : OutlinedButton(
                  onPressed: onDetailsPressed,
                  child: const Text('View Details'),
                ),
          ),
        ],
      ),
    );
  }
}
