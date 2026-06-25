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
    /// A typed, stable identifier for a linter rule.
    ///
    /// `Lint.Rule.ID` is `Tagged<Lint.Rule, Swift.String>` — the value is a
    /// `String` (e.g., `"unchecked call site"`) but its type carries the
    /// rule-domain identity at compile time. Mixing rule IDs with file IDs,
    /// config keys, or other String identifiers is rejected at the type
    /// system, not at runtime.
    ///
    /// Construction via the `ExpressibleByStringLiteral` conformance shipped
    /// by `swift-tagged-primitives`'s standard-library-integration target:
    ///
    /// ```swift
    /// let id: Lint.Rule.ID = "unchecked call site"
    /// ```
    public typealias ID = Tagged<Lint.Rule, Swift.String>
}
