class UserPasswordStore {
  static final Map<String, String> _passwords = {};

  static void setPassword(String userId, String password) {
    _passwords[userId] = password;
  }

  static String? passwordOf(String userId) {
    return _passwords[userId];
  }

  static void removePassword(String userId) {
    _passwords.remove(userId);
  }

  static void clearAll() {
    _passwords.clear();
  }
}
