class ApiConstants {
  static const baseUrl = "https://posttest.somee.com/api";
  
  /// الرابط الأساسي للصور المرفوعة (بدون /api)
  /// لأن الصور تُحفظ على /uploads وليس /api/uploads
  static const imageBaseUrl = "https://posttest.somee.com";

  static const register = "/auth/register";
  static const login = "/auth/login";
  static const refresh = "/auth/refresh";
  static const logout = "/auth/logout";
}
