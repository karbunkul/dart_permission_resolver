## 0.9.7-pre

* **Pure Dart Package**: Rebranded and refactored into a pure, framework-agnostic Dart package `permission_resolver`.
* **Generic Context**: Introduced strongly typed generic context `<C>` across `Permission<C>`, `PermissionPredicate<C>`, and `PermissionResolver<C>` for compile-time type safety.
* **Encapsulated Resolver**: Converted `PermissionResolver<C>` into an instance class with encapsulated context state.
* **Streamlined Predicates**: `Permission<C>` now implements `PermissionPredicate<C>`, enabling direct rule composition (`permissions`, `Every`, `Any`, `Not`) without requiring `Single` wrappers.
* **DartDoc**: Added comprehensive DartDoc documentation and usage examples across all public APIs.
