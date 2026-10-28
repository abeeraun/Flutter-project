import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/priority_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingView();
          if (provider.errorMessage != null) {
            return ErrorView(message: provider.errorMessage!, onRetry: provider.loadSummary);
          }
          final summary = provider.summary;
          final completion = (summary.completionRate / 100).clamp(0.0, 1.0);
          return RefreshIndicator(
            onRefresh: provider.loadSummary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Color(0x1A4A4853), blurRadius: 14, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('أهلًا، عبير!', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 5),
                            const Text('خططي ليومك\nوحققي تقدمك', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, height: 1.15, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 7),
                            Text('اليوم: ${_todayLabel()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => _showNotifications(context, summary), icon: const Icon(Icons.notifications_none, color: AppColors.primary, size: 28)),
                      const CircleAvatar(
                        radius: 19,
                        backgroundColor: AppColors.lavender,
                        child: Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.12,
                  children: [
                    _stat('إجمالي المواد', summary.subjectsCount.toString(), Icons.menu_book, AppColors.blue),
                    _stat('المهام غير المكتملة', summary.pendingTasksCount.toString(), Icons.edit_outlined, AppColors.warning),
                    _stat('الاختبارات القادمة', summary.upcomingExamsCount.toString(), Icons.event_outlined, AppColors.primary),
                    _stat('إنجاز المهام', '${summary.completionRate.toStringAsFixed(0)}%', Icons.trending_up, AppColors.mint),
                  ],
                ),
                const SizedBox(height: 22),
                _sectionTitle('نظرة عامة على التقدم'),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(value: completion, strokeWidth: 8, backgroundColor: AppColors.primary.withValues(alpha: .1), color: AppColors.primary),
                              Text('${summary.completionRate.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_progressTitle(summary.completionRate), style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 6),
                              Text(_progressMessage(summary.completionRate), style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(value: completion, minHeight: 8, backgroundColor: AppColors.background, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _sectionTitle('أولويات اليوم'),
                const SizedBox(height: 10),
                if (summary.todayPriorities.isEmpty)
                  const EmptyView(message: 'لا توجد مهام ذات أولوية الآن.', icon: Icons.task_alt)
                else
                  ...summary.todayPriorities.map(
                    (task) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: _iconBox(Icons.check_circle_outline, AppColors.mint),
                        title: Text(task.title),
                        subtitle: Text('التسليم ${task.dueDate}'),
                        trailing: PriorityBadge(priority: task.priority),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                _sectionTitle('الاختبارات القادمة'),
                const SizedBox(height: 10),
                if (summary.upcomingExams.isEmpty)
                  const EmptyView(message: 'لا توجد اختبارات قادمة.', icon: Icons.event_available)
                else
                  ...summary.upcomingExams.map(
                    (exam) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: _iconBox(Icons.school_outlined, AppColors.primary),
                        title: Text(exam.title),
                        subtitle: Text(exam.subjectName),
                        trailing: Text(exam.examDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showNotifications(BuildContext context, dynamic summary) {
    final notifications = <String>[
      ...summary.upcomingExams.map((exam) => 'اختبار قادم: ${exam.title} في ${exam.examDate}'),
      ...summary.todayPriorities.map((task) => 'مهمة ذات أولوية: ${task.title}'),
    ];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('التنبيهات', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                Expanded(
                  child: notifications.isEmpty
                      ? const SingleChildScrollView(
                          child: EmptyView(
                            message: 'لا توجد تنبيهات',
                            icon: Icons.notifications_none,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 2),
                          itemBuilder: (_, index) {
                            final item = notifications[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.notifications_active_outlined,
                                color: AppColors.primary,
                              ),
                              title: Text(item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _progressTitle(double rate) {
    if (rate <= 0) return 'جاهزة لبدء التقدم؟';
    if (rate < 25) return 'بداية جيدة!';
    if (rate < 50) return 'أنتِ تتقدمين بشكل جيد!';
    if (rate < 75) return 'أكثر من نصف الطريق!';
    if (rate < 100) return 'اقتربتِ جدًا من إكمال أهدافك!';
    return 'رائع! أنجزتِ جميع مهامك!';
  }

  String _progressMessage(double rate) {
    if (rate <= 0) return 'ابدئي بمهمة واحدة اليوم، وكل خطوة تصنع فرقًا.';
    if (rate < 25) return 'استمري في إنجاز مهامك خطوة بخطوة.';
    if (rate < 50) return 'استمري بهذا الإيقاع وستصلين إلى أهدافك.';
    if (rate < 75) return 'أداؤك ممتاز، واصلي حتى تكملي ما تبقى.';
    if (rate < 100) return 'لم يتبقَ الكثير، أنتِ على وشك الوصول!';
    return 'كل المهام مكتملة. أحسنتِ على هذا الإنجاز!';
  }

  Widget _sectionTitle(String title) => Text(title, style: Theme.of(context).textTheme.titleLarge);

  String _todayLabel() {
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]}';
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)),
      child: Icon(icon, color: color),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [_iconBox(icon, color), const Spacer(), const Icon(Icons.arrow_outward, size: 15, color: AppColors.textSecondary)]),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
