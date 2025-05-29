class PerformanceConfig {
  // نجعل المتغيرات ديناميكية بدلاً من ثابتة
  static String API_SERVER = "http://192.168.0.200:8000";
  static const int API_TIMEOUT_SECONDS = 120;

  // نقاط نهاية API
  static String get ANALYZE_PERFORMANCE_ENDPOINT =>
      "$API_SERVER/analyze-performance";
  static String get GENERATE_STUDY_PLAN_ENDPOINT =>
      "$API_SERVER/generate-study-plan";
  static String get LEARNING_RESOURCES_ENDPOINT =>
      "$API_SERVER/learning-resources";
  static String get TEST_API_ENDPOINT => "$API_SERVER/test-api";
}
