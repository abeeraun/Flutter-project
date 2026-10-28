import 'package:flutter/foundation.dart';
import '../models/task_item.dart';
import '../repositories/task_repository.dart';
import '../utils/api_exception.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  TaskProvider(this._repository);

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  List<TaskItem> get tasks {
    return _tasks.where((task) {
      final matchesStatus =
          _statusFilter == null || task.status == _statusFilter;
      final matchesPriority =
          _priorityFilter == null || task.priority == _priorityFilter;
      return matchesStatus && matchesPriority;
    }).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _tasks = await _repository.fetchTasks();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  Future<bool> addTask(TaskItem task) async {
    _errorMessage = null;
    try {
      final created = await _repository.createTask(task);
      _tasks = [..._tasks, created];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editTask(int id, TaskItem task) async {
    _errorMessage = null;
    try {
      final updated = await _repository.updateTask(id, task);
      _tasks = _tasks.map((t) => t.id == id ? updated : t).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeTask(int id) async {
    _errorMessage = null;
    try {
      await _repository.deleteTask(id);
      _tasks = _tasks.where((t) => t.id != id).toList();
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
