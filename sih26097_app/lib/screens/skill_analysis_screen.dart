import 'package:flutter/material.dart';
import 'recommendations_screen.dart';
import '../services/api_service.dart';

class SkillAnalysisScreen extends StatefulWidget {
  final UserProfile profile;
  
  const SkillAnalysisScreen({super.key, required this.profile});

  @override
  State<SkillAnalysisScreen> createState() => _SkillAnalysisScreenState();
}

class _SkillAnalysisScreenState extends State<SkillAnalysisScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  RecommendationResponse? _recommendationResponse;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      final response = await _apiService.getRecommendations(widget.profile);
      if (mounted) {
        setState(() {
          _recommendationResponse = response;
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

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
            : _buildAnalysisContent(context, theme);
  }

  Widget _buildAnalysisContent(BuildContext context, ThemeData theme) {
    if (_recommendationResponse == null) return const SizedBox.shrink();

    final skillAnalysis = _recommendationResponse!.skillAnalysis;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    String careerBeingAnalyzed = "General Livelihood";
    String matchInfo = "Analysis complete based on your profile.";
    if (_recommendationResponse!.recommendations.isNotEmpty) {
       final bestMatch = _recommendationResponse!.recommendations.first;
       careerBeingAnalyzed = bestMatch.title;
       matchInfo = "${bestMatch.matchPercentage}% Match - ${bestMatch.matchLevel}";
    }

    final currentSkillsCard = _buildSkillCard(
      theme,
      "Current Skills",
      "Skills you already possess",
      skillAnalysis.currentSkills.isNotEmpty ? skillAnalysis.currentSkills : ["None reported"],
      Icons.check_circle,
      Colors.green,
    );

    final skillsToImproveCard = _buildSkillCard(
      theme,
      "Skills to Improve",
      "Skill gap to address",
      skillAnalysis.missingSkills.isNotEmpty ? skillAnalysis.missingSkills : ["You have all required skills!"],
      Icons.warning_amber_rounded,
      Colors.orange.shade800,
    );

    final summaryCard = _buildSummaryCard(
      theme, 
      careerBeingAnalyzed, 
      matchInfo, 
      skillAnalysis.matchedSkills, 
      skillAnalysis.missingSkills,
    );

    final actionButton = SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecommendationsScreen(recommendations: _recommendationResponse!.recommendations)),
          );
        },
        icon: const Icon(Icons.arrow_forward),
        label: const Text("View Work Suggestions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );

    if (isDesktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Skills to Learn", 
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              "These are the skills you need for your best job matches.", 
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      currentSkillsCard,
                      const SizedBox(height: 32),
                      skillsToImproveCard,
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      summaryCard,
                      const SizedBox(height: 32),
                      actionButton,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Skills to Learn", 
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              "These are the skills you need for your best job matches.", 
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            summaryCard,
            const SizedBox(height: 32),
            currentSkillsCard,
            const SizedBox(height: 32),
            skillsToImproveCard,
            const SizedBox(height: 48),
            actionButton,
          ],
        ),
      );
    }
  }

  Widget _buildSummaryCard(ThemeData theme, String career, String matchInfo, List<String> matched, List<String> missing) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, size: 36, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Skill Summary",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Analyzed Career",
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            career,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Match Info",
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            matchInfo,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${matched.length}",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    "Matched Skills",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${missing.length}",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    "Skills to Learn",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(ThemeData theme, String title, String subtitle, List<String> skills, IconData icon, Color color) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30), 
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 36),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text(
                        skill,
                        style: TextStyle(
                          color: color.withAlpha(255),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
