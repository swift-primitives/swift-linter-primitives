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

/// The rule namespace.
///
/// Concrete rules nest as `Lint.Rule.X` and conform to ``Lint/Rule/Protocol``
/// per [PKG-NAME-002]. Phase 1 ships one rule at L3: `Lint.Rule.Unchecked`
/// (R5).
extension Lint {
    public enum Rule {}
}
