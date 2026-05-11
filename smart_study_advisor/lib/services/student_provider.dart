import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/course.dart';
import '../services/api_service.dart';

class StudentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Student state
  Set<String> _completedCourses = {};
  Set<String> _interests = {};

  // Loaded data
  List<Course> _allCourses = [];
  List<Course> _recommendations = [];
  List<Course> _eligibleCourses = [];
  Stats? _stats;

  // Loading states
  bool _loadingCourses = false;
  bool _loadingRecommendations = false;
  bool _loadingStats = false;
  String? _error;

  // Getters
  Set<String> get completedCourses => _completedCourses;
  Set<String> get interests => _interests;
  List<Course> get allCourses => _allCourses;
  List<Course> get recommendations => _recommendations;
  List<Course> get eligibleCourses => _eligibleCourses;
  Stats? get stats => _stats;
  bool get loadingCourses => _loadingCourses;
  bool get loadingRecommendations => _loadingRecommendations;
  bool get loadingStats => _loadingStats;
  String? get error => _error;

  bool isCourseCompleted(String code) => _completedCourses.contains(code);
  bool hasInterest(String category) => _interests.contains(category);

  StudentProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final completedJson = prefs.getString('completed_courses');
    final interestsJson = prefs.getString('interests');
    if (completedJson != null) {
      _completedCourses = Set<String>.from(jsonDecode(completedJson));
    }
    if (interestsJson != null) {
      _interests = Set<String>.from(jsonDecode(interestsJson));
    }
    notifyListeners();
    await fetchAllCourses();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'completed_courses', jsonEncode(_completedCourses.toList()));
    await prefs.setString('interests', jsonEncode(_interests.toList()));
  }

  void toggleCourseCompleted(String code) {
    if (_completedCourses.contains(code)) {
      _completedCourses.remove(code);
    } else {
      _completedCourses.add(code);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void toggleInterest(String category) {
    if (_interests.contains(category)) {
      _interests.remove(category);
    } else {
      _interests.add(category);
    }
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> fetchAllCourses() async {
    _loadingCourses = true;
    _error = null;
    notifyListeners();
    try {
      _allCourses = await _api.getAllCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingCourses = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations() async {
    _loadingRecommendations = true;
    _error = null;
    notifyListeners();
    try {
      _recommendations = await _api.getRecommendations(
        completed: _completedCourses.toList(),
        interests: _interests.toList(),
      );
      _eligibleCourses = await _api.getEligible(
        completed: _completedCourses.toList(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingRecommendations = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    _loadingStats = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await _api.getStats(completed: _completedCourses.toList());
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingStats = false;
      notifyListeners();
    }
  }
}
