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

/// A single linter match emitted by a rule.
///
/// Composes typed primitives from the ecosystem:
///
/// - ``Source/Location`` — file identity (fileID + filePath) and a typed
///   `Text.Location` (line + column) — never raw `Int` positions.
/// - ``Diagnostic/Severity`` — semantic severity (error / warning / note /
///   remark) — never a per-package severity duplicate.
///
/// **Open Question (surfaced 2026-05-06)**: `swift-diagnostic-primitives`
/// presently exposes only the severity type and a namespace; no concrete
/// diagnostic record. `Lint.Finding` is the linter's record type — a
/// candidate for promotion to `swift-diagnostic-primitives` as a generic
/// `Diagnostic.Record` (or similar) so other diagnostic-emitting tools
/// (compiler-tier audits, build-graph checkers) can consume the same shape.
/// Until promotion lands, `Lint.Finding` is the canonical linter record.
extension Lint {
    public struct Finding: Sendable, Hashable {
        /// Self-contained source location (file identity + line:column).
        public let location: Source.Location

        /// Semantic severity from `swift-diagnostic-primitives`.
        public let severity: Diagnostic.Severity

        /// The rule's stable identifier (per ``Lint/Rule/Protocol/id``).
        public let ruleID: Swift.String

        /// Human-readable explanation of the match.
        public let message: Swift.String

        @inlinable
        public init(
            location: Source.Location,
            severity: Diagnostic.Severity,
            ruleID: Swift.String,
            message: Swift.String
        ) {
            self.location = location
            self.severity = severity
            self.ruleID = ruleID
            self.message = message
        }
    }
}

extension Lint.Finding: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.location != rhs.location { return lhs.location < rhs.location }
        if lhs.severity != rhs.severity { return lhs.severity < rhs.severity }
        if lhs.ruleID != rhs.ruleID { return lhs.ruleID < rhs.ruleID }
        return lhs.message < rhs.message
    }
}
