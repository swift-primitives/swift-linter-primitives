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

extension Lint.Rule.Suppression {
    /// One concrete inline-suppression directive shape.
    ///
    /// The cases mirror the two directive forms recognized by the linter:
    /// `// swift-linter:disable:next <rule-id>` and
    /// `// swift-linter:disable:line <rule-id>`.
    public enum Directive: Sendable, Equatable {
        /// Suppresses a finding on the line after the directive.
        case next

        /// Suppresses a finding on the directive's own line.
        case line
    }
}
