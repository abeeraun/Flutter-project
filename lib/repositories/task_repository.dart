import '../models/task_item.dart';
import '../services/api_service.dart';

class TaskRepository {
  final ApiService _apiService;

  TaskRepository(this._apiService);

  Future<List<TaskItem>> fetchTasks() async {
    final data = await _apiService.get('/tasks');
    final List<dynamic> list = data['data'] as List<dynamic>;
    return list
        .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskItem> createTask(TaskItem task) async {
    final data = await _apiService.post('/tasks', task.toJson());
    return TaskItem.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<TaskItem> updateTask(int id, TaskItem task) async {
    final data = await _apiService.put('/tasks/$id', task.toJson());
    return TaskItem.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    await _apiService.delete('/tasks/$id');
  }
}
