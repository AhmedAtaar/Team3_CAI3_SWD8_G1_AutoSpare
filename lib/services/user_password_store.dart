// lib/services/user_password_store.dart

class UserPasswordStore {
  // خريطة بسيطة في الذاكرة لحفظ كلمات المرور حسب الـ userId
  static final Map<String, String> _passwords = {};

  /// تخزين/تحديث كلمة المرور لمستخدم معيّن
  static void setPassword(String userId, String password) {
    _passwords[userId] = password;
  }

  /// الحصول على كلمة المرور المخزّنة لمستخدم معيّن
  static String? passwordOf(String userId) {
    return _passwords[userId];
  }

  /// حذف باسورد مستخدم واحد (مثلاً عند حذف الحساب)
  static void removePassword(String userId) {
    _passwords.remove(userId);
  }

  /// مسح كل كلمات المرور من الذاكرة (للاختبارات أو reset عام)
  static void clearAll() {
    _passwords.clear();
  }
}
