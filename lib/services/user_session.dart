enum UserRole { buyer, seller, admin }

class UserSession {
  static bool loggedIn = false;

  static String? username;
  static String? email;
  static String? phone;

  static UserRole? authRole;

  static bool canSell = false;
  static bool canTow = false;
  static String? towCompanyId;

  static UserRole currentRole = UserRole.buyer;

  static bool get isAdmin => authRole == UserRole.admin;

  static bool get canSellRole => authRole == UserRole.seller;

  static bool get isSellerNow => !isAdmin && currentRole == UserRole.seller;

  static bool get isBuyerNow => !isAdmin && currentRole == UserRole.buyer;

  static bool get canSwitchToSeller => canSell && isBuyerNow;
  static bool get canSwitchToBuyer => isSellerNow;

  static void initFromProfile({
    required String name,
    String? email,
    String? phone,
    required UserRole role,
    bool canSell = false,
    bool canTow = false,
    String? towCompanyId,
  }) {
    username = name;
    UserSession.email = email;
    UserSession.phone = phone;

    authRole = role;
    loggedIn = true;

    UserSession.canSell = canSell;
    UserSession.canTow = canTow;
    UserSession.towCompanyId = towCompanyId;

    currentRole = isAdmin
        ? UserRole.admin
        : (canSell ? UserRole.seller : UserRole.buyer);
  }

  static void switchToBuyer() {
    if (!isAdmin && isSellerNow) {
      currentRole = UserRole.buyer;
    }
  }

  static void switchToSeller() {
    if (!isAdmin && canSwitchToSeller) {
      currentRole = UserRole.seller;
    }
  }

  static void signOut() {
    loggedIn = false;
    username = null;
    email = null;
    phone = null;
    authRole = null;
    currentRole = UserRole.buyer;
    canSell = false;
    canTow = false;
    towCompanyId = null;
  }
}
