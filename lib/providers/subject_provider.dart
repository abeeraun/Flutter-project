import 'package:flutter/foundation.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';
import '../utils/api_exception.dart';

class SubjectProvider extends ChangeNotifier {
  final SubjectRepository _repository;

  SubjectProvider(this._repository);

  List<Subject> _subjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Subject? subjectById(int id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadSubjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _subjects = await _repository.fetchSubjects();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSubject(Subject subject) async {
    _errorMessage = null;
    try {
      final created = await _repository.createSubject(subject);
      _subjects = [..._subjects, created];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editSubject(int id, Subject subject) async {
    _errorMessage = null;
    try {
      final updated = await _repository.updateSubject(id, subject);
      _subjects = _subjects.map((s) => s.id == id ? updated : s).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeSubject(int id) async {
    _errorMessage = null;
    try {
      await _repository.deleteSubject(id);
      _subjects = _subjects.where((s) => s.id != id).toList();
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
