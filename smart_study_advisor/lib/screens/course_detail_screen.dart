import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_provider.dart';
import '../services/api_service.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseCode;

  const CourseDetailScreen({super.key, required this.courseCode});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final ApiService _api = ApiService();
  Course? _course;
  Map<String, dynamic>? _prereqTree;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final course = await _api.getCourseDetail(widget.courseCode);
      final tree = await _api.getPrerequisiteTree(widget.courseCode);
      setState(() {
        _course = course;
        _prereqTree = tree;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_course?.name ?? 'Course Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: AppTheme.error)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final course = _course!;
    final provider = context.read<StudentProvider>();
    final isCompleted = provider.isCourseCompleted(course.code);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.categoryColor(course.category).withOpacity(0.15),
                  AppTheme.surfaceElevated,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: AppTheme.categoryColor(course.category)
                      .withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Tag(course.category,
                        AppTheme.categoryColor(course.category)),
                    const SizedBox(width: 8),
                    _Tag(
                        course.difficulty,
                        course.difficulty == 'easy'
                            ? AppTheme.easy
                            : course.difficulty == 'medium'
                                ? AppTheme.medium
                                : AppTheme.hard),
                    const SizedBox(width: 8),
                    _Tag('Level ${course.level}', AppTheme.textMuted),
                  ],
                ),
                const SizedBox(height: 12),
                Text(course.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(course.code.toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Complete toggle button
          Consumer<StudentProvider>(
            builder: (context, provider, _) {
              final completed = provider.isCourseCompleted(course.code);
              return GestureDetector(
                onTap: () => provider.toggleCourseCompleted(course.code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: completed
                        ? AppTheme.success.withOpacity(0.12)
                        : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: completed
                          ? AppTheme.success.withOpacity(0.5)
                          : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: completed
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        completed
                            ? 'Marked as Complete'
                            : 'Mark as Complete',
                        style: TextStyle(
                          color: completed
                              ? AppTheme.success
                              : AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Prerequisites
          if (_prereqTree != null && _prereqTree!.isNotEmpty) ...[
            const SectionHeader(
              title: 'Prerequisites',
              subtitle: 'Courses you need to complete first',
            ),
            _PrerequisiteTree(tree: _prereqTree!),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _PrerequisiteTree extends StatelessWidget {
  final Map<String, dynamic> tree;

  const _PrerequisiteTree({required this.tree});

  @override
  Widget build(BuildContext context) {
    return _buildNode(tree, 0);
  }

  Widget _buildNode(Map<String, dynamic> node, int depth) {
    final code = node['code'] ?? '';
    final name = node['name'] ?? node['display_name'] ?? code;
    final children =
        (node['prerequisites'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final difficulty = node['difficulty'] ?? 'easy';

    final diffColor = difficulty == 'easy'
        ? AppTheme.easy
        : difficulty == 'medium'
            ? AppTheme.medium
            : AppTheme.hard;

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                if (depth > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.subdirectory_arrow_right_rounded,
                        size: 14, color: AppTheme.textMuted),
                  ),
                Expanded(
                  child: Text(name,
                      style: TextStyle(
                          color: depth == 0
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: depth == 0
                              ? FontWeight.w600
                              : FontWeight.w500)),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: diffColor),
                ),
              ],
            ),
          ),
          ...children.map((child) => _buildNode(child, depth + 1)),
        ],
      ),
    );
  }
}
