import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../models/subject.dart';

class ExamFormSheet extends StatefulWidget {
  final Exam? exam;
  final List<Subject> subjects;
  final Future<bool> Function(String title, int subjectId, String examDate,
      int totalMarks, int? obtainedMarks, ExamStatus status) onSubmit;

  const ExamFormSheet({
    super.key,
    this.exam,
    required this.subjects,
    required this.onSubmit,
  });

  @override
  State<ExamFormSheet> createState() => _ExamFormSheetState();
}

class _ExamFormSheetState extends State<ExamFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _totalMarksController;
  late TextEditingController _obtainedMarksController;
  int? _subjectId;
  DateTime _examDate = DateTime.now();
  late ExamStatus _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam?.title ?? '');
    _totalMarksController = TextEditingController(
        text: widget.exam?.totalMarks.toString() ?? '100');
    _obtainedMarksController = TextEditingController(
        text: widget.exam?.obtainedMarks?.toString() ?? '');
    _subjectId = widget.exam?.subjectId ??
        (widget.subjects.isNotEmpty ? widget.subjects.first.id : null);
    _status = widget.exam?.status ?? ExamStatus.upcoming;
    if (widget.exam != null && widget.exam!.examDate.isNotEmpty) {
      _examDate = DateTime.tryParse(widget.exam!.examDate) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalMarksController.dispose();
    _obtainedMarksController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _examDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjectId == null) return;
    setState(() => _isSubmitting = true);
    final dateString =
        '${_examDate.year.toString().padLeft(4, '0')}-${_examDate.month.toString().padLeft(2, '0')}-${_examDate.day.toString().padLeft(2, '0')}';
    final obtained = _obtainedMarksController.text.trim().isEmpty
        ? null
        : int.tryParse(_obtainedMarksController.text.trim());
    final success = await widget.onSubmit(
      _titleController.text.trim(),
      _subjectId!,
      dateString,
      int.tryParse(_totalMarksController.text.trim()) ?? 100,
      obtained,
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
        '${_examDate.year.toString().padLeft(4, '0')}-${_examDate.month.toString().padLeft(2, '0')}-${_examDate.day.toString().padLeft(2, '0')}';
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
              widget.exam == null ? 'إضافة اختبار' : 'تعديل الاختبار',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان الاختبار'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'عنوان الاختبار مطلوب'
                  : null,
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
                decoration: const InputDecoration(labelText: 'تاريخ الاختبار'),
                child: Text(dateString),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalMarksController,
                    decoration:
                        const InputDecoration(labelText: 'الدرجة الكاملة'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'هذا الحقل مطلوب'
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _obtainedMarksController,
                    decoration: const InputDecoration(
                        labelText: 'درجتك (اختياري)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExamStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'الحالة'),
              items: ExamStatus.values
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(s == ExamStatus.upcoming ? 'قادم' : 'مكتمل')))
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
                  : Text(widget.exam == null ? 'حفظ الاختبار' : 'تحديث الاختبار'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          ],
        ),
      ),
      ),
    );
  }
}
