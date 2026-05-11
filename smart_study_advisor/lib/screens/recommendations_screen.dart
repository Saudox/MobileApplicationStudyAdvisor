import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'course_detail_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Advisor',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        provider.interests.isEmpty
                            ? 'Set your interests on the Dashboard first'
                            : 'Based on ${provider.interests.join(', ')}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      // Get Recommendations Button
                      GestureDetector(
                        onTap: () async {
                          await provider.fetchRecommendations();
                          setState(() => _hasLoaded = true);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accent,
                                AppTheme.accent.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (provider.loadingRecommendations)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              else
                                const Icon(Icons.auto_awesome_rounded,
                                    color: Colors.black, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                provider.loadingRecommendations
                                    ? 'Thinking...'
                                    : 'Get Recommendations',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tab bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelColor: AppTheme.accent,
                          unselectedLabelColor: AppTheme.textSecondary,
                          labelStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(
                              text:
                                  'For You (${provider.recommendations.length})',
                            ),
                            Tab(
                              text:
                                  'Eligible (${provider.eligibleCourses.length})',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _RecommendationList(
                        courses: provider.recommendations,
                        completedCodes: provider.completedCourses,
                        hasLoaded: _hasLoaded,
                        isLoading: provider.loadingRecommendations,
                        emptyTitle: 'No personalized recommendations',
                        emptySubtitle:
                            'Add your interests on the Dashboard and tap "Get Recommendations"',
                        isRecommended: true,
                      ),
                      _RecommendationList(
                        courses: provider.eligibleCourses,
                        completedCodes: provider.completedCourses,
                        hasLoaded: _hasLoaded,
                        isLoading: provider.loadingRecommendations,
                        emptyTitle: 'No eligible courses found',
                        emptySubtitle:
                            'Complete some courses first to unlock more',
                        isRecommended: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecommendationList extends StatelessWidget {
  final List courses;
  final Set<String> completedCodes;
  final bool hasLoaded;
  final bool isLoading;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isRecommended;

  const _RecommendationList({
    required this.courses,
    required this.completedCodes,
    required this.hasLoaded,
    required this.isLoading,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (_, __) => const ShimmerCard(),
      );
    }

    if (!hasLoaded) {
      return const EmptyState(
        icon: Icons.auto_awesome_outlined,
        title: 'Ready to advise',
        subtitle: 'Tap the button above to get your personalized plan',
      );
    }

    if (courses.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_rounded,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: courses.length,
      itemBuilder: (context, idx) {
        final course = courses[idx];
        return CourseCard(
          course: course,
          isCompleted: completedCodes.contains(course.code),
          isRecommended: isRecommended,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(courseCode: course.code),
            ),
          ),
        );
      },
    );
  }
}
