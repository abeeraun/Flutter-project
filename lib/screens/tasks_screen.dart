import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/subject_provider.dart';
import '../models/task_item.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';
import '../widgets/task_form_sheet.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      context.read<SubjectProvider>().loadSubjects();
    });
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  void _form({TaskItem? task}) {
    final provider = context.read<TaskProvider>();
    final subjects = context.read<SubjectProvider>().subjects;
    if (subjects.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف مادة دراسية أولًا.'))); return; }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => TaskFormSheet(
        task: task,
        subjects: subjects,
        onSubmit: (title, description, subjectId, dueDate, priority, status) async {
          final item = TaskItem(id: task?.id ?? 0, title: title, description: description, subjectId: subjectId, subjectName: '', dueDate: dueDate, priority: priority, status: status, createdAt: task?.createdAt ?? '');
          return task == null ? provider.addTask(item) : provider.editTask(task.id, item);
        },
      ),
    );
  }

  Future<void> _delete(TaskItem task) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('حذف المهمة'), content: Text('هل تريد حذف "${task.title}"؟'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف'))]));
    if (yes == true && mounted) await context.read<TaskProvider>().removeTask(task.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => _form(), child: const Icon(Icons.add)),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final query = _search.text.trim().toLowerCase();
          final tasks = provider.tasks.where((t) => t.title.toLowerCase().contains(query) || t.subjectName.toLowerCase().contains(query)).toList();
          return Column(
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 54, 20, 8), child: Row(children: [Expanded(child: Text('المهام', style: Theme.of(context).textTheme.headlineSmall)), IconButton(onPressed: () => _form(), icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30))])),
              Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 10), child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'ابحث عن مهمة...', prefixIcon: Icon(Icons.search)))),
              _filters(provider),
              Expanded(
                child: provider.isLoading
                    ? const LoadingView()
                    : provider.errorMessage != null && provider.tasks.isEmpty
                        ? ErrorView(message: provider.errorMessage!, onRetry: provider.loadTasks)
                        : tasks.isEmpty
                            ? const EmptyView(message: 'لا توجد مهام مطابقة.', icon: Icons.checklist_outlined)
                            : RefreshIndicator(onRefresh: provider.loadTasks, child: ListView.builder(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), itemCount: tasks.length, itemBuilder: (_, index) => _taskCard(tasks[index]))),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _taskCard(TaskItem task) {
    final completed = task.status == TaskStatus.completed;
    final color = AppTheme.priorityColor(priorityToString(task.priority));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.assignment_outlined, color: color)),
        title: Text(task.title, style: TextStyle(fontWeight: FontWeight.w700, decoration: completed ? TextDecoration.lineThrough : null)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text('${task.subjectName}  •  التسليم ${task.dueDate}')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriorityBadge(priority: priorityToString(task.priority)),
            const SizedBox(width: 6),
            StatusBadge(status: statusToString(task.status)),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') _form(task: task);
                if (value == 'delete') _delete(task);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('تعديل')),
                PopupMenuItem(value: 'delete', child: Text('حذف')),
              ],
            ),
          ],
        ),
        onTap: () => _form(task: task),
      ),
    );
  }

  Widget _filters(TaskProvider provider) {
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _chip('الكل', provider.statusFilter == null, () => provider.setStatusFilter(null)),
          ...TaskStatus.values.map((s) => _chip(_statusLabel(s), provider.statusFilter == s, () => provider.setStatusFilter(s))),
          const SizedBox(width: 8),
          _chip('كل الأولويات', provider.priorityFilter == null, () => provider.setPriorityFilter(null)),
          ...TaskPriority.values.map((p) => _chip(_priorityLabel(p), provider.priorityFilter == p, () => provider.setPriorityFilter(p))),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: const VisualDensity(horizontal: -1, vertical: -1), label: Text(label, maxLines: 1, overflow: TextOverflow.visible, style: const TextStyle(fontSize: 11)), selected: selected, onSelected: (_) => onTap(), selectedColor: AppColors.primary, labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)));
  }

  String _priorityLabel(TaskPriority priority) => switch (priority) { TaskPriority.low => 'منخفضة', TaskPriority.medium => 'متوسطة', TaskPriority.high => 'عالية' };
  String _statusLabel(TaskStatus status) => switch (status) { TaskStatus.pending => 'قيد الانتظار', TaskStatus.inProgress => 'قيد التنفيذ', TaskStatus.completed => 'مكتملة' };
}
