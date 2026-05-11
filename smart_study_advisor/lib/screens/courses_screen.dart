import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/course.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _searchQuery = '';
  String? _filterDifficulty;
  String? _filterCategory;
  int? _filterLevel;
  bool _showOnlyIncomplete = false;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Course> _filtered(List<Course> courses, Set<String> completed) {
    return courses.where((c) {
      if (_searchQuery.isNotEmpty &&
          !c.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !c.code.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterDifficulty != null && c.difficulty != _filterDifficulty) {
        return false;
      }
      if (_filterCategory != null && c.category != _filterCategory) {
        return false;
      }
      if (_filterLevel != null && c.level != _filterLevel) return false;
      if (_showOnlyIncomplete && completed.contains(c.code)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final filtered =
            _filtered(provider.allCourses, provider.completedCourses);

        // Group by level
        final Map<int, List<Course>> grouped = {};
        for (final c in filtered) {
          grouped.putIfAbsent(c.level, () => []).add(c);
        }
        final levels = grouped.keys.toList()..sort();

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(provider),
                _buildFilters(),
                Expanded(
                  child: provider.loadingCourses
                      ? ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: 6,
                          itemBuilder: (_, __) => const ShimmerCard(),
                        )
                      : filtered.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'No courses found',
                              subtitle: 'Try adjusting your filters',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: levels.length,
                              itemBuilder: (context, idx) {
                                final level = levels[idx];
                                final courses = grouped[level]!;
                                return _LevelSection(
                                  level: level,
                                  courses: courses,
                                  completedCodes: provider.completedCourses,
                                  onToggle: provider.toggleCourseCompleted,
                                  onTap: (course) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CourseDetailScreen(
                                          courseCode: course.code),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(StudentProvider provider) {
    final completedCount = provider.completedCourses.length;
    final totalCount = provider.allCourses.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Courses',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    Text('Tap the circle to mark as complete',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Text('$completedCount / $totalCount done',
                    style: const TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search courses...',
                hintStyle:
                    TextStyle(color: AppTheme.textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppTheme.textMuted, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          _FilterChip(
            label: _showOnlyIncomplete ? 'Incomplete only' : 'All',
            active: _showOnlyIncomplete,
            onTap: () =>
                setState(() => _showOnlyIncomplete = !_showOnlyIncomplete),
            icon: Icons.filter_alt_rounded,
          ),
          const SizedBox(width: 8),
          for (final diff in ['easy', 'medium', 'hard'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: diff,
                active: _filterDifficulty == diff,
                onTap: () => setState(() => _filterDifficulty =
                    _filterDifficulty == diff ? null : diff),
                color: diff == 'easy'
                    ? AppTheme.easy
                    : diff == 'medium'
                        ? AppTheme.medium
                        : AppTheme.hard,
              ),
            ),
          for (final cat in [
            'math', 'programming', 'hardware', 'theory', 'ai', 'systems'
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: cat,
                active: _filterCategory == cat,
                onTap: () => setState(() =>
                    _filterCategory = _filterCategory == cat ? null : cat),
                color: AppTheme.categoryColor(cat),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? c.withOpacity(0.15) : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? c : AppTheme.border, width: active ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: active ? c : AppTheme.textMuted),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                    color: active ? c : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  final int level;
  final List<Course> courses;
  final Set<String> completedCodes;
  final Function(String) onToggle;
  final Function(Course) onTap;

  static const _levelNames = {
    0: 'Foundation Year',
    1: 'Year 1',
    2: 'Year 2',
    3: 'Year 3',
  };

  const _LevelSection({
    required this.level,
    required this.courses,
    required this.completedCodes,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = courses.where((c) => completedCodes.contains(c.code)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Text(_levelNames[level] ?? 'Level $level',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('$completed/${courses.length}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
        ...courses.map((course) => CourseCard(
              course: course,
              isCompleted: completedCodes.contains(course.code),
              onTap: () => onTap(course),
              onToggleComplete: () => onToggle(course.code),
            )),
      ],
    );
  }
}
