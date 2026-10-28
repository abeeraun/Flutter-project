import 'package:flutter/foundation.dart';
import '../models/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';
import '../utils/api_exception.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardProvider(this._repository);

  DashboardSummary _summary = DashboardSummary.empty();
  bool _isLoading = false;
  String? _errorMessage;

  DashboardSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _summary = await _repository.fetchSummary();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadSummary();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
