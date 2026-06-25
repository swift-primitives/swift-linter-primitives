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

extension Array where Element == Lint.Rule.Configuration {
    /// Returns this bundle minus entries whose rule ID is in `excluded`.
    ///
    /// The canonical use case is brand-newtype-owning primitive packages
    /// (swift-ordinal-primitives, swift-affine-primitives,
    /// swift-cardinal-primitives) that own typed-primitive recognizer
    /// rules — they exclude those rules at consumer call sites while
    /// preserving cross-package firing.
    ///
    /// ```swift
    /// Lint.Configuration {
    ///     Lint.Rule.Bundle.primitives.excluding(rules: [
    ///         "raw value access",
    ///         "chained rawvalue access",
    ///     ])
    /// }
    /// ```
    @inlinable
    public func excluding(rules excluded: Set<Lint.Rule.ID>) -> [Lint.Rule.Configuration] {
        self.filter { !excluded.contains($0.rule.id) }
    }
}
