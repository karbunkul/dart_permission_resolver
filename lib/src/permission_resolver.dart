import 'control_mode.dart';
import 'permission.dart';
import 'permission_predicate.dart';

/// Central resolver class for evaluating permissions and predicate rules.
///
/// Holds an encapsulated optional context [_context] of type [C].
///
/// Example:
/// ```dart
/// final resolver = PermissionResolver<UserSession>(userSession);
/// final isAllowed = await resolver.permission(PremiumPermission());
/// ```
class PermissionResolver<C> {
  final C? _context;

  /// Creates a [PermissionResolver] instance bound to an optional [_context].
  const PermissionResolver([this._context]);

  /// Resolves a single [permission] against the encapsulated context.
  Future<bool> permission(Permission<C> permission) async {
    return permission.request(_context);
  }

  /// Evaluates whether ALL [predicates] resolve to `true` (Logical AND).
  Future<bool> every(List<PermissionPredicate<C>> predicates) {
    return Every<C>(predicates).resolve(_context);
  }

  /// Evaluates whether AT LEAST ONE of the [predicates] resolves to `true` (Logical OR).
  Future<bool> any(List<PermissionPredicate<C>> predicates) {
    return Any<C>(predicates).resolve(_context);
  }

  /// Evaluates a list of [predicates] according to the specified [mode] (`ControlMode.every` or `ControlMode.any`).
  Future<bool> permissions(
    List<PermissionPredicate<C>> predicates, {
    ControlMode mode = ControlMode.every,
  }) async {
    final res = await Future.wait(
      predicates.map((group) async {
        return group.resolve(_context);
      }),
    );

    final sum = res.fold<int>(0, (ac, element) => element ? ac + 1 : ac);

    switch (mode) {
      case ControlMode.every:
        return sum == predicates.length;
      case ControlMode.any:
        return sum > 0;
    }
  }

  /// Static helper method for one-off single permission resolution without instantiating a resolver.
  static Future<bool> resolvePermission<C>({
    C? context,
    required Permission<C> permission,
  }) {
    return PermissionResolver<C>(context).permission(permission);
  }

  /// Static helper method for one-off 'every' permission resolution without instantiating a resolver.
  static Future<bool> resolveEvery<C>({
    C? context,
    required List<PermissionPredicate<C>> predicates,
  }) {
    return PermissionResolver<C>(context).every(predicates);
  }

  /// Static helper method for one-off 'any' permission resolution without instantiating a resolver.
  static Future<bool> resolveAny<C>({
    C? context,
    required List<PermissionPredicate<C>> predicates,
  }) {
    return PermissionResolver<C>(context).any(predicates);
  }

  /// Static helper method for one-off predicate resolution without instantiating a resolver.
  static Future<bool> resolvePredicates<C>({
    C? context,
    required List<PermissionPredicate<C>> predicates,
    ControlMode mode = ControlMode.every,
  }) {
    return PermissionResolver<C>(context).permissions(predicates, mode: mode);
  }
}
