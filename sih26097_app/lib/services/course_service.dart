import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';

class Course {
  final String id;
  final String title;
  final String provider;
  final String nsqfLevel;
  final String duration;
  final List<String> skillsDeveloped;
  final String description;
  final String eligibility;
  final String category;
  
  // Enrolled course specific fields
  final int progress;
  final String status;

  Course({
    required this.id,
    required this.title,
    required this.provider,
    required this.nsqfLevel,
    required this.duration,
    required this.skillsDeveloped,
    required this.description,
    required this.eligibility,
    required this.category,
    this.progress = 0,
    this.status = 'Not Started',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      provider: json['provider'] ?? '',
      nsqfLevel: json['nsqf_level'] ?? '',
      duration: json['duration'] ?? '',
      skillsDeveloped: (json['skills_developed'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      description: json['description'] ?? '',
      eligibility: json['eligibility'] ?? '',
      category: json['category'] ?? '',
      progress: json['progress'] ?? 0,
      status: json['status'] ?? 'Not Started',
    );
  }
}

class CourseService {
  static final CourseService _instance = CourseService._internal();
  factory CourseService() => _instance;
  CourseService._internal();

  Future<List<Course>> getExploreCourses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/courses'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['courses'] as List).map((e) => Course.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Course>> getMyCourses() async {
    final userId = AuthService().currentUserMobile;
    if (userId == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/courses/enrolled/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['enrolled_courses'] as List).map((e) => Course.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> registerForCourse(String courseId) async {
    final userId = AuthService().currentUserMobile;
    if (userId == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/courses/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'course_id': courseId,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
