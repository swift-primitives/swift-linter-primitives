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

extension Lint.Configuration {
    /// Property.View on ``Lint/Configuration`` for rule-related leaves.
    ///
    /// The View follows the institute's larger.smaller naming principle:
    /// `rules` is the View accessor; the leaves describe specific rule
    /// vantages. Per-layer leaves live directly on the View; chain-resolved
    /// leaves live under ``effective``.
    public struct Rules: Sendable {
        @usableFromInline
        internal let _config: Lint.Configuration

        /// Creates the rules View over the given configuration layer.
        @inlinable
        public init(_config: Lint.Configuration) {
            self._config = _config
        }

        /// Rule entries authored at this configuration layer.
        @inlinable
        public var entries: [Lint.Rule.Configuration] {
            _config._ruleEntries
        }

        /// Rule IDs disabled wholesale at this configuration layer.
        @inlinable
        public var disabled: Set<Lint.Rule.ID> {
            _config._disabledRules
        }

        /// Chain-resolved sub-view: ``Effective/entries`` returns the
        /// flattened entries across the parent chain (with later layers
        /// overriding earlier ones per rule ID, and disabled entries
        /// dropped); ``Effective/disabled`` returns the union of
        /// disabled IDs across the chain.
        @inlinable
        public var effective: Effective {
            Effective(_config: _config)
        }
    }
}
