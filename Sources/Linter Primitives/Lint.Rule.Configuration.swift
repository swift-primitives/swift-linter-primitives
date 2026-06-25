// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linter-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-linter-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Lint.Rule {
    /// Per-rule configuration entry.
    ///
    /// Carries a rule witness value (``Lint/Rule``) plus the per-package
    /// adjustments: enable/disable mode and an optional severity override.
    /// Path filtering folds INTO the witness via
    /// ``Lint/Rule/filtered(toPaths:)`` rather than alongside the entry —
    /// the ``enable(_:severity:paths:)`` factory applies the combinator
    /// internally so call sites read the same as before.
    ///
    /// Constructed via the typed factory methods (``enable(_:severity:paths:)``,
    /// ``disable(_:)``, ``override(_:severity:)``). Call sites read as
    /// `.enable(.\`unchecked call site\`)`, resolved by static-member lookup
    /// against ``Lint/Rule`` — natural-English backtick names mirror the
    /// ecosystem's `@Test` naming convention.
    public struct Configuration: Sendable {
        /// The rule witness — its data identity.
        ///
        /// When the entry was constructed with a `paths:` filter, the stored
        /// witness has the filter folded in via ``Lint/Rule/filtered(toPaths:)``.
        public let rule: Lint.Rule

        /// Whether this entry enables or disables the rule for the
        /// configured scope.
        public let mode: Mode

        /// Optional severity override.
        ///
        /// `nil` falls back to the rule's ``Lint/Rule/Severity/default``.
        public let severity: Diagnostic.Severity?

        /// Creates an entry from a rule witness, mode, and optional
        /// severity override.
        @inlinable
        public init(
            rule: Lint.Rule,
            mode: Mode,
            severity: Diagnostic.Severity? = nil
        ) {
            self.rule = rule
            self.mode = mode
            self.severity = severity
        }
    }
}

// MARK: - Factories

extension Lint.Rule.Configuration {
    /// Activates a rule, with optional severity override and path filter.
    ///
    /// When `paths` is non-nil, the rule is wrapped via
    /// ``Lint/Rule/filtered(toPaths:)`` before being stored, so the
    /// engine sees a single rule value with filtering already folded in.
    @inlinable
    public static func enable(
        _ rule: Lint.Rule,
        severity: Diagnostic.Severity? = nil,
        paths: Lint.Filter? = nil
    ) -> Self {
        let stored = paths.map(rule.filtered(toPaths:)) ?? rule
        return Self(rule: stored, mode: .enabled, severity: severity)
    }

    /// Disables a rule for the configured scope.
    @inlinable
    public static func disable(_ rule: Lint.Rule) -> Self {
        Self(rule: rule, mode: .disabled, severity: nil)
    }

    /// Overrides a rule's severity without changing its enable/disable mode.
    ///
    /// Equivalent to ``enable(_:severity:paths:)`` with severity set; this
    /// factory exists to express call-site intent ("override severity")
    /// distinct from "enable a previously-disabled rule".
    @inlinable
    public static func override(
        _ rule: Lint.Rule,
        severity: Diagnostic.Severity
    ) -> Self {
        Self(rule: rule, mode: .enabled, severity: severity)
    }
}
