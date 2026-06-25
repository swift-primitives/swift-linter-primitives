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

/// Composition operators on ``Lint/Rule``.
///
/// Witnesses-as-data unlocks transformations the protocol shape could not
/// express without an existential wrapper. These operators let the
/// engine reduce to a trivial fold over `[Lint.Rule]`: per-rule path
/// filtering, severity overrides, and rule-pack composition fold INTO
/// the witness rather than threading alongside it.
extension Lint.Rule {
    /// Returns a rule that emits findings only for sources whose path
    /// matches `filter`.
    ///
    /// Sources outside the filter produce no findings.
    ///
    /// Folds per-rule path filtering into the witness. The engine's
    /// per-source loop becomes a single fold over `[Lint.Rule]` — there
    /// is no per-entry `paths:` branch to thread. The configuration-level
    /// ``Lint/Rule/Configuration/enable(_:severity:paths:)`` factory
    /// applies this combinator internally when its `paths:` argument is
    /// non-nil, so call sites read the same as before.
    @inlinable
    public func filtered(toPaths filter: Lint.Filter) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: self.severity.default,
            findings: { (source: borrowing Lint.Source.Parsed, severity) in
                guard filter.matches(sourcePath: source.path) else { return [] }
                return self.findings(source, severity)
            }
        )
    }

    /// Returns a rule whose default severity is replaced.
    ///
    /// The engine's severity-resolution step
    /// (`config.severity ?? rule.severity.default`) then picks up the new
    /// default automatically.
    @inlinable
    public func with(default severity: Diagnostic.Severity) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: severity,
            findings: self.findings
        )
    }

    /// Returns a rule that emits at a fixed severity, ignoring the
    /// severity argument threaded by the engine.
    ///
    /// Use when a downstream configuration has already resolved severity
    /// and the rule should honor that resolution exactly.
    @inlinable
    public func pinned(to severity: Diagnostic.Severity) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: severity,
            findings: { (source: borrowing Lint.Source.Parsed, _) in
                self.findings(source, severity)
            }
        )
    }

    /// Returns a composite rule that runs every child rule against the
    /// same parsed source and concatenates findings in input order.
    ///
    /// The composite carries `id` and a default severity itself; children
    /// supply their own findings at the severity threaded through the
    /// composite. Useful for packaging a rule set as a single witness.
    @inlinable
    public static func combining(
        id: Lint.Rule.ID,
        default severity: Diagnostic.Severity,
        _ rules: [Lint.Rule]
    ) -> Lint.Rule {
        Lint.Rule(
            id: id,
            default: severity,
            findings: { (source: borrowing Lint.Source.Parsed, severity) in
                var out: [Diagnostic.Record] = []
                for rule in rules {
                    out.append(contentsOf: rule.findings(source, severity))
                }
                return out
            }
        )
    }
}
