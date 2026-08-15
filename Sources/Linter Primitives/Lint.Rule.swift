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

extension Lint {
    /// A lint rule, as a witness value.
    ///
    /// A rule is data: a typed identity, a severity View, an inline-suppression
    /// policy, and a pure function that maps a parsed source plus a resolved
    /// severity to a list of findings. There is no protocol conformance, no
    /// type-level identity, and no `init(severity:)` factory — severity is
    /// threaded into the closure by the engine at run time.
    ///
    /// Rule packs publish rules as static values on this type. Both the
    /// Swift identifier and the stable `id` string use the same
    /// backtick-quoted natural-English phrase (mirroring the
    /// `@Test func \`natural english\`()` convention used in the
    /// ecosystem's test suites). The id-string is what consumers see in
    /// diagnostics and reporters; aligning it with the Swift identifier
    /// removes the snake_case/natural-language duality that used to require
    /// two forms per rule:
    ///
    /// ```swift
    /// extension Lint.Rule {
    ///     public static let `unchecked call site` = Lint.Rule(
    ///         id: "unchecked call site",
    ///         default: .warning,
    ///         findings: { source, severity in
    ///             // visit `source.tree`, emit records at `severity`
    ///         }
    ///     )
    /// }
    /// ```
    ///
    /// Consumers reference rules by static-member access in the configuration
    /// DSL — call sites read as natural English:
    ///
    /// ```swift
    /// Lint.Configuration {
    ///     .enable(.`unchecked call site`)
    ///     .override(.`try optional`, severity: .error)
    /// }
    /// ```
    ///
    /// Mistyping a rule name is a compile error, resolved by static-member
    /// lookup against this type.
    public struct Rule: Sendable {
        /// Stable identifier carried in configurations and emitted findings.
        ///
        /// Typed via ``Lint/Rule/ID`` (`Tagged<Lint.Rule, String>`) so
        /// rule-domain identity is a phantom tag at compile time.
        public let id: Lint.Rule.ID

        /// Severity View on the rule.
        ///
        /// Read the default severity via ``Lint/Rule/Severity/default``; the
        /// engine resolves severity once per run
        /// (`configuration.severity ?? rule.severity.default`) and threads it
        /// through ``findings``.
        public let severity: Severity

        /// Inline-suppression directive shapes this rule sanctions.
        ///
        /// Rules default to ``Lint/Rule/Suppression/none`` and must opt in
        /// explicitly. This declaration does not itself scan directives or
        /// elide findings; the `swift-linter` engine owns applying it.
        public let suppression: Suppression

        /// Pure mapping from `(parsed source, resolved severity)` to findings.
        ///
        /// The engine resolves severity once per run
        /// (`configuration.severity ?? rule.severity.default`) and threads it
        /// through this closure. Rules do not store severity.
        public let findings:
            @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) -> [Diagnostic.Record]

        /// Canonical in-place fix for this rule's findings, when the rule
        /// specifies one that is expressible as a whole-file rewrite.
        ///
        /// A rule declares a fix by supplying a pure function from a parsed
        /// source to the rewritten source text. Returning `nil` means "this
        /// file needs no change" — either the rule found nothing, or every
        /// finding in the file falls outside the autofixable subset. A rule
        /// MUST NOT return text for a finding whose canonical fix it cannot
        /// derive with certainty: an unfixable finding stays a finding.
        ///
        /// `nil` on the rule itself means the rule has no autofix at all,
        /// which is the default. Rules whose fix requires emitting or
        /// deleting *other* files (file splits, extension moves) are not
        /// expressible here by construction, and keep `fix` `nil`.
        ///
        /// The engine applies fixes file-by-file, re-parsing between rules so
        /// each rewriter sees the previous one's output. It never applies a
        /// rewrite it cannot re-parse.
        public let fix: (@Sendable (borrowing Lint.Source.Parsed) -> Swift.String?)?

        /// Creates a rule from its identifier, default severity,
        /// inline-suppression policy, findings closure, and optional
        /// canonical fix.
        ///
        /// Existing declarations that omit `suppression` sanction no inline
        /// directive shape; declarations that omit `fix` have no autofix.
        @inlinable
        public init(
            id: Lint.Rule.ID,
            default severity: Diagnostic.Severity,
            suppression: Lint.Rule.Suppression = .none,
            findings:
                @escaping @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) ->
                [Diagnostic.Record],
            fix: (@Sendable (borrowing Lint.Source.Parsed) -> Swift.String?)? = nil
        ) {
            self.id = id
            self.severity = Severity(default: severity)
            self.suppression = suppression
            self.findings = findings
            self.fix = fix
        }
    }
}
