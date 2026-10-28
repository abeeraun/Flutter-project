import '../models/dashboard_summary.dart';
import '../services/api_service.dart';

class DashboardRepository {
  final ApiService _apiService;

  DashboardRepository(this._apiService);

  Future<DashboardSummary> fetchSummary() async {
    final data = await _apiService.get('/dashboard/summary');
    return DashboardSummary.fromJson(data['data'] as Map<String, dynamic>);
  }
}
