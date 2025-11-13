// lib/services/user_session.dart
import 'package:flutter/material.dart';

/// دور المستخدم الموحّد على مستوى المشروع
enum UserRole { buyer, seller, admin }

/// إدارة جلسة المستخدم الموحّدة على مستوى التطبيق كله
class UserSession {
  static bool loggedIn = false;
  static String? username;
  static UserRole? authRole;

  static bool get isAdmin => authRole == UserRole.admin;
  static bool get canSell => authRole == UserRole.seller;

  static UserRole currentRole = UserRole.buyer;

  static void initFromProfile({required String name, required UserRole role}) {
    username = name;
    authRole = role;
    loggedIn = true;
    currentRole = canSell ? UserRole.seller : UserRole.buyer;
  }

  static bool get isSellerNow => !isAdmin && currentRole == UserRole.seller;
  static bool get isBuyerNow  => !isAdmin && currentRole == UserRole.buyer;

  static bool get canSwitchToSeller => canSell && isBuyerNow;
  static bool get canSwitchToBuyer  => isSellerNow;

  static void switchToBuyer() {
    if (!isAdmin && isSellerNow) currentRole = UserRole.buyer;
  }

  static void switchToSeller() {
    if (!isAdmin && canSwitchToSeller) currentRole = UserRole.seller;
  }

  static void signOut() {
    loggedIn = false;
    username = null;
    authRole = null;
    currentRole = UserRole.buyer;
  }
}
