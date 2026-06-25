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
    /// Severity View on ``Lint/Rule``.
    ///
    /// Property.View surface for severity-related leaves on a rule. The View
    /// follows the institute's larger.smaller naming principle: `severity`
    /// is the View accessor; the leaves describe specific severity
    /// resolutions. Today the only leaf is ``default`` (the severity used
    /// when a configuration does not override it); future leaves may
    /// surface engine-threaded or configuration-resolved severities.
    public struct Severity: Sendable {
        /// Default severity used when a configuration entry does not
        /// override it.
        public let `default`: Diagnostic.Severity

        /// Creates a severity View from the rule's default severity.
        @inlinable
        public init(default severity: Diagnostic.Severity) {
            self.default = severity
        }
    }
}
