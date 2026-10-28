import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/subject_form_sheet.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SubjectProvider>().loadSubjects());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _showForm({Subject? subject}) {
    final provider = context.read<SubjectProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SubjectFormSheet(
        subject: subject,
        onSubmit: (name, description, teacher, color) async {
          final item = Subject(id: subject?.id ?? 0, name: name, description: description, teacher: teacher, color: color, createdAt: subject?.createdAt ?? '');
          return subject == null ? provider.addSubject(item) : provider.editSubject(subject.id, item);
        },
      ),
    );
  }

  Future<void> _delete(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المادة'),
        content: Text('هل تريد حذف "${subject.name}"؟ سيتم حذف المهام والاختبارات المرتبطة بها.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await context.read<SubjectProvider>().removeSubject(subject.id);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<SubjectProvider>().errorMessage ?? 'تعذر حذف المادة. تحقق من اتصال الجهاز بالخادم.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
      body: Consumer<SubjectProvider>(
        builder: (context, provider, _) {
          final query = _search.text.trim().toLowerCase();
          final subjects = provider.subjects.where((s) => s.name.toLowerCase().contains(query) || s.teacher.toLowerCase().contains(query)).toList();
          return Column(
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 54, 20, 8), child: Row(children: [Expanded(child: Text('المواد الدراسية', style: Theme.of(context).textTheme.headlineSmall)), IconButton(onPressed: () => _showForm(), icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30))])),
              Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'ابحث عن مادة...', prefixIcon: Icon(Icons.search)))),
              Expanded(
                child: provider.isLoading
                    ? const LoadingView()
                    : provider.errorMessage != null && provider.subjects.isEmpty
                        ? ErrorView(message: provider.errorMessage!, onRetry: provider.loadSubjects)
                        : subjects.isEmpty
                            ? const EmptyView(message: 'لا توجد مواد. اضغط + لإضافة مادة.', icon: Icons.menu_book_outlined)
                            : RefreshIndicator(
                                onRefresh: provider.loadSubjects,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                                  itemCount: subjects.length,
                                  itemBuilder: (_, index) => _subjectCard(subjects[index]),
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _subjectCard(Subject subject) {
    final color = _color(subject.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.menu_book, color: color, size: 27)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(subject.name, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), Text(subject.teacher.isEmpty ? 'لم تتم إضافة مدرس' : subject.teacher, style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 4), Text(subject.description.isEmpty ? 'جاهزة لجلسة المذاكرة القادمة' : subject.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)])),
            PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') _showForm(subject: subject); if (value == 'delete') _delete(subject); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('تعديل')), PopupMenuItem(value: 'delete', child: Text('حذف'))]),
          ],
        ),
      ),
    );
  }

  Color _color(String value) {
    try { return Color(int.parse(value.replaceFirst('#', '0xFF'))); } catch (_) { return AppColors.primary; }
  }
}
