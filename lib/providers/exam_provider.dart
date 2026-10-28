import 'package:flutter/foundation.dart';
import '../models/exam.dart';
import '../repositories/exam_repository.dart';
import '../utils/api_exception.dart';

class ExamProvider extends ChangeNotifier {
  final ExamRepository _repository;

  ExamProvider(this._repository);

  List<Exam> _exams = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Exam> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get completedCount =>
      _exams.where((e) => e.status == ExamStatus.completed).length;

  double get averageScore {
    final completed = _exams
        .where((e) =>
            e.status == ExamStatus.completed && e.obtainedMarks != null)
        .toList();
    if (completed.isEmpty) return 0;
    final total = completed.fold<double>(
        0, (sum, e) => sum + (e.obtainedMarks! / e.totalMarks * 100));
    return total / completed.length;
  }

  Future<void> loadExams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _exams = await _repository.fetchExams();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExam(Exam exam) async {
    _errorMessage = null;
    try {
      final created = await _repository.createExam(exam);
      _exams = [..._exams, created];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editExam(int id, Exam exam) async {
    _errorMessage = null;
    try {
      final updated = await _repository.updateExam(id, exam);
      _exams = _exams.map((e) => e.id == id ? updated : e).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeExam(int id) async {
    _errorMessage = null;
    try {
      await _repository.deleteExam(id);
      _exams = _exams.where((e) => e.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
