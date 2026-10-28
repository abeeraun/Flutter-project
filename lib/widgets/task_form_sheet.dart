import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/subject.dart';

class TaskFormSheet extends StatefulWidget {
  final TaskItem? task;
  final List<Subject> subjects;
  final Future<bool> Function(String title, String description, int subjectId,
      String dueDate, TaskPriority priority, TaskStatus status) onSubmit;

  const TaskFormSheet({
    super.key,
    this.task,
    required this.subjects,
    required this.onSubmit,
  });

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  int? _subjectId;
  DateTime _dueDate = DateTime.now();
  late TaskPriority _priority;
  late TaskStatus _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _subjectId = widget.task?.subjectId ??
        (widget.subjects.isNotEmpty ? widget.subjects.first.id : null);
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _status = widget.task?.status ?? TaskStatus.pending;
    if (widget.task != null && widget.task!.dueDate.isNotEmpty) {
      _dueDate = DateTime.tryParse(widget.task!.dueDate) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjectId == null) return;
    setState(() => _isSubmitting = true);
    final dateString =
        '${_dueDate.year.toString().padLeft(4, '0')}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}';
    final success = await widget.onSubmit(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _subjectId!,
      dateString,
      _priority,
      _status,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${_dueDate.year.toString().padLeft(4, '0')}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.task == null ? 'إضافة مهمة' : 'تعديل المهمة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان المهمة'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'عنوان المهمة مطلوب'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'الوصف'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _subjectId,
              decoration: const InputDecoration(labelText: 'المادة الدراسية'),
              items: widget.subjects
                  .map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (value) => setState(() => _subjectId = value),
              validator: (value) =>
                  value == null ? 'اختر المادة الدراسية' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'تاريخ التسليم'),
                child: Text(dateString),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'الأولوية'),
              items: TaskPriority.values
                  .map((p) => DropdownMenuItem(
                      value: p, child: Text(_priorityLabel(p))))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _priority = value ?? _priority),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'الحالة'),
              items: TaskStatus.values
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(_statusLabel(s))))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child:
                          CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(widget.task == null ? 'حفظ المهمة' : 'تحديث المهمة'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          ],
        ),
      ),
      ),
    );
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return 'منخفضة';
      case TaskPriority.medium: return 'متوسطة';
      case TaskPriority.high: return 'عالية';
    }
  }

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending: return 'قيد الانتظار';
      case TaskStatus.inProgress: return 'قيد التنفيذ';
      case TaskStatus.completed: return 'مكتملة';
    }
  }
}
