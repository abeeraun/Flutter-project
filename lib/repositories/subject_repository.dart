import '../models/subject.dart';
import '../services/api_service.dart';

class SubjectRepository {
  final ApiService _apiService;

  SubjectRepository(this._apiService);

  Future<List<Subject>> fetchSubjects() async {
    final data = await _apiService.get('/subjects');
    final List<dynamic> list = data['data'] as List<dynamic>;
    return list
        .map((e) => Subject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Subject> createSubject(Subject subject) async {
    final data = await _apiService.post('/subjects', subject.toJson());
    return Subject.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Subject> updateSubject(int id, Subject subject) async {
    final data = await _apiService.put('/subjects/$id', subject.toJson());
    return Subject.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteSubject(int id) async {
    await _apiService.delete('/subjects/$id');
  }
}
