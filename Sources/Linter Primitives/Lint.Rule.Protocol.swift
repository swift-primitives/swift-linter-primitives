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

public import SwiftSyntax

/// The rule capability per [PKG-NAME-002].
///
/// A rule consumes a parsed Swift source file (represented as a
/// `SourceFileSyntax` plus a `SourceLocationConverter` for line:column
/// resolution) plus a `Source.File` identity, and emits zero or more
/// ``Lint/Finding`` values.
///
/// Rules are pure — they do not modify the syntax tree. The orchestrator
/// (at L3) parses each file exactly once and runs every enabled rule against
/// the same tree.
extension Lint.Rule {
    public protocol `Protocol`: Sendable {
        /// Stable identifier used in configuration files and emitted findings.
        ///
        /// Convention: `lower_snake_case` (e.g., `unchecked_call_site`).
        static var id: Swift.String { get }

        /// Default severity emitted by this rule. Configurable per-package via
        /// the canonical YAML config consumed at L3.
        var severity: Diagnostic.Severity { get }

        /// Run this rule against one parsed source file.
        ///
        /// - Parameters:
        ///   - source: The file's identity (used to enrich emitted findings).
        ///   - tree: Parsed source-file syntax.
        ///   - converter: Maps `AbsolutePosition` to (line, column).
        /// - Returns: Findings for every match, in source order.
        func findings(
            in source: Source.File,
            tree: SourceFileSyntax,
            converter: SourceLocationConverter
        ) -> [Lint.Finding]
    }
}
