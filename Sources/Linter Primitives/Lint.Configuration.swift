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

/// Activated rules for a single linter run.
///
/// Phase 1 ships a minimal flat schema (a set of activated rule IDs).
/// `parent_config:` URL chaining mirroring SwiftLint's mechanism is deferred
/// to Phase 2 — the chain semantics are well-understood; the wire format is
/// what's punted. For Phase 1 the canonical Tier 1 / Tier 2 configs are read
/// flat (no inheritance), and a single per-package config supplies overrides.
extension Lint {
    public struct Configuration: Sendable, Hashable {
        public let activatedRuleIDs: Set<Swift.String>

        @inlinable
        public init(activatedRuleIDs: Set<Swift.String>) {
            self.activatedRuleIDs = activatedRuleIDs
        }

        /// Empty configuration — no rules fire.
        public static let empty: Self = .init(activatedRuleIDs: [])

        @inlinable
        public func isActivated(_ ruleID: Swift.String) -> Bool {
            activatedRuleIDs.contains(ruleID)
        }
    }
}
