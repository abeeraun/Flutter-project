import '../models/exam.dart';
import '../services/api_service.dart';

class ExamRepository {
  final ApiService _apiService;

  ExamRepository(this._apiService);

  Future<List<Exam>> fetchExams() async {
    final data = await _apiService.get('/exams');
    final List<dynamic> list = data['data'] as List<dynamic>;
    return list.map((e) => Exam.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Exam> createExam(Exam exam) async {
    final data = await _apiService.post('/exams', exam.toJson());
    return Exam.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Exam> updateExam(int id, Exam exam) async {
    final data = await _apiService.put('/exams/$id', exam.toJson());
    return Exam.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteExam(int id) async {
    await _apiService.delete('/exams/$id');
  }
}
