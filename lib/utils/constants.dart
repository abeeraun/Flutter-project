class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.71.34.95/studyflow_api',
  );
  static const Duration timeoutDuration = Duration(seconds: 20);
}

class AppStrings {
  static const String appName = 'StudyFlow';
  static const String genericError = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  static const String noInternet = 'تعذر الوصول إلى الخادم. تحقق من عنوان API والشبكة وتشغيل Apache وMySQL.';
  static const String noData = 'لا توجد بيانات متاحة.';
}
