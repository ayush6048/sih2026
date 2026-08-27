import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UserProfile {
  final String? education;
  final String? occupation;
  final List<String> skills;
  final List<String> interests;
  final String? location;
  final String? careerGoal;

  UserProfile({
    this.education,
    this.occupation,
    this.skills = const [],
    this.interests = const [],
    this.location,
    this.careerGoal,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      education: json['education'] as String?,
      occupation: json['occupation'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      location: json['location'] as String?,
      careerGoal: json['career_goal'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'education': education,
      'occupation': occupation,
      'skills': skills,
      'interests': interests,
      'location': location,
      'career_goal': careerGoal,
    };
  }
}

class ConversationResponse {
  final String reply;
  final Map<String, dynamic>? extractedData;
  final UserProfile? profile;
  final String? nextField;
  final bool isProfileComplete;

  ConversationResponse({
    required this.reply, 
    this.extractedData,
    this.profile,
    this.nextField,
    required this.isProfileComplete,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      reply: json['reply'] ?? "Sorry, I couldn't process that.",
      extractedData: json['extracted_data'] as Map<String, dynamic>?,
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      nextField: json['next_field'] as String?,
      isProfileComplete: json['is_profile_complete'] ?? false,
    );
  }
}

class SkillAnalysis {
  final List<String> currentSkills;
  final List<String> matchedSkills;
  final List<String> missingSkills;

  SkillAnalysis({
    required this.currentSkills,
    required this.matchedSkills,
    required this.missingSkills,
  });

  factory SkillAnalysis.fromJson(Map<String, dynamic> json) {
    return SkillAnalysis(
      currentSkills: (json['current_skills'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      matchedSkills: (json['matched_skills'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      missingSkills: (json['missing_skills'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class CareerRecommendation {
  final String careerId;
  final String title;
  final int matchPercentage;
  final String matchLevel;
  final String description;
  final List<String> whyRecommended;
  final List<String> skillGapAddressed;
  final String nsqfLevel;
  final List<String> trainingIds;

  CareerRecommendation({
    required this.careerId,
    required this.title,
    required this.matchPercentage,
    required this.matchLevel,
    required this.description,
    required this.whyRecommended,
    required this.skillGapAddressed,
    required this.nsqfLevel,
    required this.trainingIds,
  });

  factory CareerRecommendation.fromJson(Map<String, dynamic> json) {
    return CareerRecommendation(
      careerId: json['career_id'] ?? '',
      title: json['title'] ?? '',
      matchPercentage: json['match_percentage'] ?? 0,
      matchLevel: json['match_level'] ?? '',
      description: json['description'] ?? '',
      whyRecommended: (json['why_recommended'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      skillGapAddressed: (json['skill_gap_addressed'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      nsqfLevel: json['nsqf_level'] ?? '',
      trainingIds: (json['training_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class RecommendationResponse {
  final SkillAnalysis skillAnalysis;
  final List<CareerRecommendation> recommendations;

  RecommendationResponse({
    required this.skillAnalysis,
    required this.recommendations,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      skillAnalysis: SkillAnalysis.fromJson(json['skill_analysis'] ?? {}),
      recommendations: (json['recommendations'] as List<dynamic>?)?.map((e) => CareerRecommendation.fromJson(e)).toList() ?? [],
    );
  }
}

class TrainingDetails {
  final String id;
  final String title;
  final String description;
  final List<String> skillsDeveloped;
  final String duration;
  final String nsqfLevel;

  TrainingDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.skillsDeveloped,
    required this.duration,
    required this.nsqfLevel,
  });

  factory TrainingDetails.fromJson(Map<String, dynamic> json) {
    return TrainingDetails(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      skillsDeveloped: (json['skills_developed'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      duration: json['duration'] ?? '',
      nsqfLevel: json['nsqf_level'] ?? '',
    );
  }
}


class Opportunity {
  final String id;
  final String title;
  final String organization;
  final String location;
  final String requiredEducation;
  final List<String> requiredSkills;
  final String type;
  final int matchPercentage;

  Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.location,
    required this.requiredEducation,
    required this.requiredSkills,
    required this.type,
    required this.matchPercentage,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      location: json['location'] ?? '',
      requiredEducation: json['required_education'] ?? '',
      requiredSkills: (json['required_skills'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      type: json['type'] ?? '',
      matchPercentage: json['match_percentage'] ?? 0,
    );
  }
}

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<ConversationResponse> sendMessage(String message, String conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conversation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'conversation_id': conversationId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ConversationResponse.fromJson(data);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unable to connect to the AI service. Please check your connection and try again.');
    }
  }

  Future<RecommendationResponse> getRecommendations(UserProfile profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecommendationResponse.fromJson(data);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unable to load recommendations. Please try again.');
    }
  }

  Future<TrainingDetails> getTrainingDetails(String trainingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/training/$trainingId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TrainingDetails.fromJson(data);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unable to load training details. Please try again.');
    }
  }

  Future<List<Opportunity>> getOpportunities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/opportunities'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['opportunities'] as List).map((e) => Opportunity.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
