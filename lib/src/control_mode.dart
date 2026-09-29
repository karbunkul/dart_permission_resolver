/// Defines how multiple permission predicates are evaluated during resolution.
enum ControlMode {
  /// Requires at least one predicate in the list to evaluate to `true`.
  any,

  /// Requires all predicates in the list to evaluate to `true`.
  every,
}
