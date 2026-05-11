import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/student_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'recommendations_screen.dart';
import 'courses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    CoursesScreen(),
    RecommendationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Advisor',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: AppTheme.accent, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('Study Advisor',
                            style: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Your Progress',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('CSE — Computer & Systems Engineering',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  if (provider.loadingStats) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final stats = provider.stats;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ProgressCard(stats: stats),
                        const SizedBox(height: 16),
                        if (stats != null) _LevelBreakdown(stats: stats),
                        const SizedBox(height: 16),
                        _InterestsCard(),
                        const SizedBox(height: 16),
                        _QuickActions(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final dynamic stats;

  const _ProgressCard({this.stats});

  @override
  Widget build(BuildContext context) {
    final pct = stats?.percentage ?? 0.0;
    final completed = stats?.completedCourses ?? 0;
    final total = stats?.totalCourses ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withOpacity(0.15),
            AppTheme.surfaceElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 52,
            lineWidth: 6,
            percent: (pct / 100).clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${pct.toInt()}%',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            progressColor: AppTheme.accent,
            backgroundColor: AppTheme.border,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Courses Complete',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text('$completed / $total',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  pct == 0
                      ? 'Start your journey!'
                      : pct < 50
                          ? 'Great start, keep going!'
                          : pct < 80
                              ? 'Over halfway there!'
                              : 'Almost done, legend!',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBreakdown extends StatelessWidget {
  final dynamic stats;

  const _LevelBreakdown({required this.stats});

  @override
  Widget build(BuildContext context) {
    final levels = stats.levels as Map<String, dynamic>;
    final levelNames = {
      '0': 'Foundation',
      '1': 'Year 1',
      '2': 'Year 2',
      '3': 'Year 3',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('By Year',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ...levels.entries.map((e) {
            final ls = e.value;
            final total = ls.total as int;
            final completed = ls.completed as int;
            final pct = total > 0 ? completed / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(levelNames[e.key] ?? 'Level ${e.key}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      const Spacer(),
                      Text('$completed/$total',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(
                        pct == 1.0 ? AppTheme.success : AppTheme.accent),
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InterestsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final allCategories = [
          'math', 'programming', 'hardware', 'theory', 'ai', 'systems', 'general'
        ];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Interests',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Used to personalize recommendations',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allCategories.map((cat) {
                  return InterestChip(
                    category: cat,
                    selected: provider.hasInterest(cat),
                    onTap: () => provider.toggleInterest(cat),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Get Advice',
            color: AppTheme.accent,
            onTap: () {
              // Navigate to advisor tab
              final home = context.findAncestorStateOfType<_HomeScreenState>();
              home?.setState(() => home._currentIndex = 2);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.menu_book_rounded,
            label: 'All Courses',
            color: AppTheme.accentSecondary,
            onTap: () {
              final home = context.findAncestorStateOfType<_HomeScreenState>();
              home?.setState(() => home._currentIndex = 1);
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
