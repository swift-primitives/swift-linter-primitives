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
    /// A linter finding: the wire-format ``Diagnostic_Primitives/Diagnostic/Record``
    /// emitted by a rule, paired with an optional ``Lint/Visibility``
    /// annotation captured by the engine.
    ///
    /// ## Why wrap the record
    ///
    /// ``Diagnostic_Primitives/Diagnostic/Record`` is an L1 type in
    /// `swift-diagnostic-primitives` — a sibling primitives package
    /// that this package depends on. Diagnostic primitives MUST NOT
    /// take a dependency on linter primitives (dependency direction is
    /// `swift-linter-primitives → swift-diagnostic-primitives`), so the
    /// visibility tag cannot live on `Diagnostic.Record` itself. The
    /// engine wraps each emitted record into ``Lint/Finding`` after the
    /// rule fires; rule findings closures continue to return
    /// `[Diagnostic.Record]` and the engine post-processes — no rule
    /// signatures change.
    ///
    /// ## Visibility semantics
    ///
    /// ``visibility`` is `nil` when the engine could not resolve the
    /// finding's source position to a declaration node (e.g., the
    /// finding lands at the source-file root, or position lookup fails).
    /// When present, the value is the effective access level of the
    /// enclosing decl chain as computed by
    /// ``Lint/Visibility/effective(of:)`` — minimum of every modifier
    /// walked from the finding's syntax node up to the source-file root.
    /// Consumers segmenting findings by visibility (e.g., empirical
    /// follow-ups against the `fileprivate`/`private` slice) read this
    /// field directly without re-walking the tree.
    ///
    /// ## Layering
    ///
    /// Reporters consume `[Lint.Finding]` and choose whether to surface
    /// visibility — the text reporter appends `[visibility: <case>]`
    /// after the SwiftLint-compatible line, the SARIF reporter emits a
    /// `properties.visibility` field per SARIF result. Consumers that
    /// only need the underlying record (CI parsers, IDE problem-matchers)
    /// access ``record`` directly; the wrapper composes pure data and
    /// adds no runtime cost beyond an optional enum case.
    public struct Finding: Sendable, Hashable {
        /// The underlying diagnostic record — source location, severity,
        /// rule identifier, and message — exactly as emitted by the rule.
        public let record: Diagnostic.Record

        /// The effective visibility of the declaration enclosing the finding.
        ///
        /// `nil` when the engine could not resolve a syntax node for the
        /// record's source position.
        public let visibility: Lint.Visibility?

        /// Wraps a diagnostic record with its optional visibility annotation.
        @inlinable
        public init(
            record: Diagnostic.Record,
            visibility: Lint.Visibility? = nil
        ) {
            self.record = record
            self.visibility = visibility
        }
    }
}
