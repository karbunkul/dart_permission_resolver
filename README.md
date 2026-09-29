# permission_resolver

A lightweight, pure Dart library for resolving permission rules and managing access control without any UI or framework dependencies.

## Features

- **Pure Dart**: Zero dependencies on Flutter or heavy frameworks. Works in Flutter apps, server-side Dart, CLI tools, and background services.
- **Type-Safe Context**: Bind strongly typed context (`PermissionResolver<UserSession>`) or pass raw context (`Object?`).
- **Encapsulated Resolver**: Instantiate `PermissionResolver(context)` once and resolve rules cleanly.
- **Composition & Predicates**: Combine permissions logically with `Every`, `Any`, `Not`, and `Reverse` without boilerplate wrappers.
- **Async & Sync**: Full support for both synchronous and asynchronous permission checks via `FutureOr<bool>`.

## Usage

### 1. Define custom permissions

```dart
import 'dart:async';
import 'package:permission_resolver/permission_resolver.dart';

class UserSession {
  final bool isDeveloper;
  final bool isPremium;
  final bool isBanned;

  UserSession({
    this.isDeveloper = false,
    this.isPremium = false,
    this.isBanned = false,
  });
}

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
```

### 2. Instantiate PermissionResolver

```dart
void main() async {
  final session = UserSession(isPremium: true, isBanned: false);

  // Bind context to resolver instance
  final resolver = PermissionResolver<UserSession>(session);

  // Single permission check
  final isPremium = await resolver.permission(PremiumPermission());
  print('Is Premium: $isPremium'); // true
}
```

## Predicates & Logical Operators

`permission_resolver` provides flexible building blocks (predicates) to construct complex access control logic. Because `Permission` itself implements `PermissionPredicate`, you can pass permissions and predicate groups interchangeably.

| Predicate / Operator | Description | Example |
| :--- | :--- | :--- |
| **`Permission`** | Base atomic rule. Evaluates `request(context)`. | `PremiumPermission()` |
| **`Reverse(permission)`** | Inverts a single permission result (Logical NOT). | `Reverse(BannedPermission())` |
| **`Not(predicate)`** | Inverts the evaluation of any predicate group. | `Not(Any([banned, suspended]))` |
| **`Every([rules...])`** | Logical AND. Resolves `true` only if **ALL** rules evaluate to `true`. | `Every([premium, Reverse(banned)])` |
| **`Any([rules...])`** | Logical OR. Resolves `true` if **AT LEAST ONE** rule evaluates to `true`. | `Any([developer, premium])` |
| **`Single(permission)`** | Explicit predicate wrapper for a single permission (optional). | `Single(PremiumPermission())` |

### Complex Rules Example

You can nest predicates to model intricate permission trees:

```dart
final canAccessBetaFeatures = await resolver.permissions([
  // Must NOT be banned
  Reverse(BannedPermission()),
  
  // AND must be EITHER a Developer OR a Premium user
  Any([
    DeveloperPermission(),
    PremiumPermission(),
  ]),
]);
```
