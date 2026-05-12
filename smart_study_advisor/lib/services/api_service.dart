import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── Courses ──────────────────────────────────────────────

  Future<List<Course>> getAllCourses({
    String? level,
    String? difficulty,
    String? category,
  }) async {
    final params = <String, String>{};
    if (level != null) params['level'] = level;
    if (difficulty != null) params['difficulty'] = difficulty;
    if (category != null) params['category'] = category;

    final uri = Uri.parse('$baseUrl/courses/')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception('Failed to load courses: ${response.statusCode}');
  }

  Future<Course> getCourseDetail(String code) async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$code/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Course.fromJson(jsonDecode(response.body));
    }
    throw Exception('Course not found');
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/categories/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    }
    throw Exception('Failed to load categories');
  }

  // ── Advisor ───────────────────────────────────────────────

  Future<List<Course>> getRecommendations({
    required List<String> completed,
    required List<String> interests,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/advisor/recommend/'),
      headers: _headers,
      body: jsonEncode({'completed': completed, 'interests': interests}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List recs = data['recommendations'] ?? [];
      return recs.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception('Failed to get recommendations: ${response.statusCode}');
  }

  Future<List<Course>> getEligible({required List<String> completed}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/advisor/eligible/'),
      headers: _headers,
      body: jsonEncode({'completed': completed}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List eligible = data['eligible_courses'] ?? [];
      return eligible.map((e) => Course.fromJson(e)).toList();
    }
    throw Exception('Failed to get eligible courses');
  }

  Future<Map<String, dynamic>> getPrerequisiteTree(String code) async {
    final response = await http.get(
      Uri.parse('$baseUrl/advisor/prerequisites/$code/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get prerequisite tree');
  }

  Future<Stats> getStats({required List<String> completed}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/advisor/stats/'),
      headers: _headers,
      body: jsonEncode({'completed': completed}),
    );
    if (response.statusCode == 200) {
      return Stats.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get stats');
  }
}
