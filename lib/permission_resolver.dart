/// A lightweight, pure Dart library for resolving permission rules and managing access control.
///
/// Provides type-safe permission resolution, logical composition predicates
/// (`Every`, `Any`, `Not`, `Reverse`), and an encapsulated [PermissionResolver].
library permission_resolver;

export 'src/control_mode.dart';
export 'src/permission.dart';
export 'src/permission_predicate.dart';
export 'src/permission_resolver.dart';
