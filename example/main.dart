import 'dart:async';

import 'package:permission_resolver/permission_resolver.dart';

/// Example User Session Context
class UserSession {
  final String name;
  final bool isDeveloper;
  final bool isPremium;
  final bool isBanned;

  UserSession({
    required this.name,
    this.isDeveloper = false,
    this.isPremium = false,
    this.isBanned = false,
  });
}

/// 1. Define permissions strongly typed to UserSession
class DeveloperPermission extends Permission<UserSession> {
  @override
  FutureOr<bool> request([UserSession? context]) {
    return context?.isDeveloper ?? false;
  }
}

class PremiumPermission extends Permission<UserSession> {
  @override
  FutureOr<bool> request([UserSession? context]) {
    return context?.isPremium ?? false;
  }
}

class BannedPermission extends Permission<UserSession> {
  @override
  FutureOr<bool> request([UserSession? context]) {
    return context?.isBanned ?? false;
  }
}

void main() async {
  final user = UserSession(
    name: 'Alice',
    isPremium: true,
    isDeveloper: false,
    isBanned: false,
  );

  // Create an instance of PermissionResolver for our user session
  final resolver = PermissionResolver(user);

  final devPermission = DeveloperPermission();
  final premiumPermission = PremiumPermission();
  final bannedPermission = BannedPermission();

  // 1. Single permission check
  final isDev = await resolver.permission(devPermission);
  print('Is Developer: $isDev'); // false

  // 2. Check if user has ALL specified permissions (Premium AND NOT Banned)
  // No Single() wrappers needed!
  final canAccessPremiumContent = await resolver.permissions(
    [
      premiumPermission,
      Reverse(bannedPermission), // NOT banned
    ],
    mode: ControlMode.every,
  );
  print('Can access premium content: $canAccessPremiumContent'); // true

  // 3. Check if user has ANY of the specified permissions (Developer OR Premium)
  final canAccessSpecialFeatures = await resolver.any([
    devPermission,
    premiumPermission,
  ]);
  print('Can access special features: $canAccessSpecialFeatures'); // true
}
