import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../providers/subject_provider.dart';
import '../models/exam.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/exam_form_sheet.dart';

class ExamsProgressScreen extends StatefulWidget {
  const ExamsProgressScreen({super.key});

  @override
  State<ExamsProgressScreen> createState() => _ExamsProgressScreenState();
}

class _ExamsProgressScreenState extends State<ExamsProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().loadExams();
      context.read<SubjectProvider>().loadSubjects();
    });
  }

  void _showForm({Exam? exam}) {
    final provider = context.read<ExamProvider>();
    final subjects = context.read<SubjectProvider>().subjects;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف مادة دراسية أولًا.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ExamFormSheet(
          exam: exam,
          subjects: subjects,
          onSubmit: (title, subjectId, examDate, totalMarks, obtainedMarks,
              status) async {
            final selectedSubject = subjects.firstWhere(
              (subject) => subject.id == subjectId,
            );
            final newExam = Exam(
              id: exam?.id ?? 0,
              title: title,
              subjectId: subjectId,
              subjectName: selectedSubject.name,
              examDate: examDate,
              totalMarks: totalMarks,
              obtainedMarks: obtainedMarks,
              status: status,
              createdAt: exam?.createdAt ?? '',
            );
            if (exam == null) {
              return provider.addExam(newExam);
            }
            return provider.editExam(exam.id, newExam);
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Exam exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الاختبار'),
        content: Text('هل تريد حذف "${exam.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final provider = context.read<ExamProvider>();
      final success = await provider.removeExam(exam.id);
      if (!success && mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاختبارات والتقدم')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingView();
          }
          if (provider.errorMessage != null && provider.exams.isEmpty) {
            return ErrorView(
              message: provider.errorMessage!,
              onRetry: () => provider.loadExams(),
            );
          }
          return RefreshIndicator(
            onRefresh: provider.loadExams,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'اختبارات مكتملة',
                        value: provider.completedCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'متوسط الدرجات',
                        value: '${provider.averageScore.toStringAsFixed(0)}%',
                        icon: Icons.bar_chart,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (provider.exams.isEmpty)
                  const EmptyView(
                    message: 'لا توجد اختبارات. اضغط + لإضافة اختبار.',
                    icon: Icons.school_outlined,
                  )
                else
                  Column(
                    children: provider.exams.map((exam) {
                      final progress = exam.obtainedMarks != null
                          ? exam.obtainedMarks! / exam.totalMarks
                          : null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      exam.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  StatusBadge(
                                      status:
                                          examStatusToString(exam.status)),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showForm(exam: exam);
                                      } else if (value == 'delete') {
                                        _confirmDelete(exam);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                          value: 'edit', child: Text('تعديل')),
                                      PopupMenuItem(
                                          value: 'delete',
                                          child: Text('حذف')),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      exam.subjectName.isEmpty
                                          ? 'لم يتم تحديد المادة'
                                          : exam.subjectName,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('التاريخ: ${exam.examDate}'),
                              const SizedBox(height: 8),
                              if (progress != null)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    LinearProgressIndicator(
                                      value: progress.clamp(0, 1),
                                      backgroundColor:
                                          AppColors.background,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${exam.obtainedMarks}/${exam.totalMarks} درجة'),
                                  ],
                                )
                              else
                                Text('الدرجة الكاملة: ${exam.totalMarks}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
