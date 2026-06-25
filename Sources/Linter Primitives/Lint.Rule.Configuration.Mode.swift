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

extension Lint.Rule.Configuration {
    /// Whether a per-rule entry enables or disables the rule for the
    /// configured scope.
    ///
    /// `enabled` activates the rule in the effective rule set; `disabled`
    /// removes it (the entry short-circuits at
    /// ``Lint/Configuration/Rules/effective`` so disabled entries never
    /// reach the engine's per-rule loop). The two-state shape is
    /// deliberate — additional modes (e.g., warning-as-error) are
    /// expressed via the ``severity`` override, not via additional
    /// `Mode` cases.
    public enum Mode: Sendable, Equatable {
        case enabled
        case disabled
    }
}
