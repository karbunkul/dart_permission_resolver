import 'permission.dart';

/// Abstract base class for logical permission predicates.
///
/// Predicates represent rule compositions that can be resolved against an optional [context].
abstract class PermissionPredicate<C> {
  /// Flat list of all leaf permissions contained within this predicate tree.
  List<Permission<C>> get permissions;

  /// Resolves this predicate against [context] and returns `true` or `false`.
  Future<bool> resolve([C? context]);
}

/// Inverts the evaluation result of any [group] predicate (Logical NOT).
///
/// Example:
/// ```dart
/// final notAccess = Not(Any([BannedPermission(), SuspendedPermission()]));
/// ```
class Not<C> implements PermissionPredicate<C> {
  /// The underlying predicate group to invert.
  final PermissionPredicate<C> group;

  /// Creates a [Not] predicate wrapping [group].
  Not(this.group);

  @override
  List<Permission<C>> get permissions => group.permissions;

  @override
  Future<bool> resolve([C? context]) async {
    return !(await group.resolve(context));
  }
}

/// Explicit predicate wrapper for a single [permission].
///
/// Note: Since [Permission] implements [PermissionPredicate] directly,
/// wrapping in [Single] is optional.
class Single<C> implements PermissionPredicate<C> {
  /// The single permission wrapped by this predicate.
  final Permission<C> permission;

  /// Creates a [Single] predicate wrapping [permission].
  Single(this.permission);

  @override
  List<Permission<C>> get permissions => [permission];

  @override
  Future<bool> resolve([C? context]) async {
    return permission.request(context);
  }
}

/// A composite predicate that evaluates to `true` if **ALL** nested [predicates] evaluate to `true` (Logical AND).
///
/// Example:
/// ```dart
/// final allConditions = Every([PremiumPermission(), Reverse(BannedPermission())]);
/// ```
class Every<C> implements PermissionPredicate<C> {
  /// The list of child predicates that must all evaluate to `true`.
  final List<PermissionPredicate<C>> predicates;

  /// Creates an [Every] predicate composite containing [predicates].
  Every(this.predicates);

  @override
  List<Permission<C>> get permissions =>
      predicates.expand((p) => p.permissions).toList();

  @override
  Future<bool> resolve([C? context]) async {
    if (predicates.isEmpty) {
      return true;
    }

    final res = await Future.wait(
      predicates.map((predicate) async {
        return predicate.resolve(context);
      }),
    );

    return res.firstWhere((element) => element == false, orElse: () => true);
  }
}

/// A composite predicate that evaluates to `true` if **AT LEAST ONE** nested predicate evaluates to `true` (Logical OR).
///
/// Example:
/// ```dart
/// final anyRole = Any([DeveloperPermission(), PremiumPermission()]);
/// ```
class Any<C> implements PermissionPredicate<C> {
  /// The list of child predicates from which at least one must evaluate to `true`.
  final List<PermissionPredicate<C>> predicates;

  /// Creates an [Any] predicate composite containing [predicates].
  Any(this.predicates);

  @override
  List<Permission<C>> get permissions =>
      predicates.expand((p) => p.permissions).toList();

  @override
  Future<bool> resolve([C? context]) async {
    if (predicates.isEmpty) {
      return true;
    }

    final res = await Future.wait(
      predicates.map((predicate) async {
        return predicate.resolve(context);
      }),
    );

    final sum = res.fold<int>(0, (ac, element) => element ? ac + 1 : ac);

    return sum > 0;
  }
}
