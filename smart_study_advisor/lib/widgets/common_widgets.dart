import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/course.dart';

// ── Course Card ────────────────────────────────────────────

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isCompleted;
  final bool isRecommended;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;

  const CourseCard({
    super.key,
    required this.course,
    this.isCompleted = false,
    this.isRecommended = false,
    this.onTap,
    this.onToggleComplete,
  });

  Color get _difficultyColor {
    switch (course.difficulty) {
      case 'easy':
        return AppTheme.easy;
      case 'medium':
        return AppTheme.medium;
      case 'hard':
        return AppTheme.hard;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.categoryColor(course.category);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.surfaceElevated.withOpacity(0.6)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRecommended
                ? AppTheme.accent.withOpacity(0.5)
                : isCompleted
                    ? AppTheme.success.withOpacity(0.3)
                    : AppTheme.border,
            width: isRecommended ? 1.5 : 1,
          ),
          boxShadow: isRecommended
              ? [
                  BoxShadow(
                      color: AppTheme.accent.withOpacity(0.08),
                      blurRadius: 12,
                      spreadRadius: 0)
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Category dot
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            style: TextStyle(
                              color: isCompleted
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('For you',
                                style: TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Tag(label: course.category, color: catColor),
                        const SizedBox(width: 6),
                        _Tag(
                            label: course.difficulty,
                            color: _difficultyColor),
                        const SizedBox(width: 6),
                        _Tag(
                            label: 'L${course.level}',
                            color: AppTheme.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
              if (onToggleComplete != null)
                GestureDetector(
                  onTap: onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTheme.success.withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.success
                            : AppTheme.border,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check,
                            size: 14, color: AppTheme.success)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Interest Chip ──────────────────────────────────────────

class InterestChip extends StatelessWidget {
  final String category;
  final bool selected;
  final VoidCallback onTap;

  const InterestChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  static const Map<String, IconData> _icons = {
    'math': Icons.functions_rounded,
    'programming': Icons.code_rounded,
    'hardware': Icons.memory_rounded,
    'theory': Icons.auto_stories_rounded,
    'ai': Icons.psychology_rounded,
    'systems': Icons.dns_rounded,
    'general': Icons.school_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColor(category);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icons[category] ?? Icons.circle,
                size: 16,
                color: selected ? color : AppTheme.textSecondary),
            const SizedBox(width: 7),
            Text(
              category,
              style: TextStyle(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading Shimmer ────────────────────────────────────────

class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader(
      {super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
