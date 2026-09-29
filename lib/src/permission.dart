import 'dart:async';

import 'permission_predicate.dart';

/// Abstract base class for defining atomic permission rules.
///
/// Generic type parameter [C] specifies the type of context needed to evaluate
/// the permission rule (e.g. `UserSession`, `BuildContext`, or `Object?`).
///
/// Example:
/// ```dart
/// class PremiumPermission extends Permission<UserSession> {
///   @override
///   FutureOr<bool> request([UserSession? context]) {
///     return context?.isPremium ?? false;
///   }
/// }
/// ```
abstract class Permission<C> implements PermissionPredicate<C> {
  /// Evaluates whether this permission is granted for the given [context].
  ///
  /// Returns `true` if granted, `false` otherwise. Can return a [Future] or a synchronous `bool`.
  FutureOr<bool> request([C? context]);

  @override
  List<Permission<C>> get permissions => [this];

  @override
  Future<bool> resolve([C? context]) async => await request(context);
}

/// Inverts the evaluation result of an underlying [permission] (Logical NOT).
///
/// Example:
/// ```dart
/// final isNotBanned = Reverse(BannedPermission());
/// ```
class Reverse<C> implements Permission<C> {
  /// The underlying permission to invert.
  final Permission<C> permission;

  /// Creates a [Reverse] wrapper around [permission].
  Reverse(this.permission);

  @override
  List<Permission<C>> get permissions => [this];

  @override
  Future<bool> resolve([C? context]) async => await request(context);

  @override
  FutureOr<bool> request([C? context]) async {
    return !(await permission.request(context));
  }
}
