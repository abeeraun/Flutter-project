import 'package:flutter/material.dart';
import '../models/subject.dart';

class SubjectFormSheet extends StatefulWidget {
  final Subject? subject;
  final Future<bool> Function(String name, String description, String teacher,
      String color) onSubmit;

  const SubjectFormSheet({
    super.key,
    this.subject,
    required this.onSubmit,
  });

  @override
  State<SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<SubjectFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _teacherController;
  final List<String> _colorOptions = const [
    '#3D5AFE',
    '#2ECC71',
    '#F39C12',
    '#E74C3C',
    '#9B59B6',
  ];
  late String _selectedColor;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.subject?.description ?? '');
    _teacherController =
        TextEditingController(text: widget.subject?.teacher ?? '');
    _selectedColor = widget.subject?.color ?? _colorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final success = await widget.onSubmit(
      _nameController.text.trim(),
      _descriptionController.text.trim(),
      _teacherController.text.trim(),
      _selectedColor,
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
              widget.subject == null ? 'إضافة مادة' : 'تعديل المادة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المادة'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'اسم المادة مطلوب'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _teacherController,
              decoration: const InputDecoration(labelText: 'اسم المدرس'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'الوصف'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: _colorOptions.map((hex) {
                final isSelected = hex == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(
                          int.parse(hex.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
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
                  : Text(widget.subject == null ? 'حفظ المادة' : 'تحديث المادة'),
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
