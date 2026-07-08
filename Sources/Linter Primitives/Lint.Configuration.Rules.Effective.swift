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

extension Lint.Configuration.Rules {
    /// Chain-resolved sub-view on ``Lint/Configuration/Rules``.
    ///
    /// Walks the parent chain rooted at the configuration that produced
    /// this view and resolves both the effective entries (with per-id
    /// override and disabled-drop) and the effective disabled set (union
    /// across all layers).
    ///
    /// Disabling axes consulted, in order:
    /// 1. ``Lint/Rule/Configuration/Mode/disabled`` on an individual entry
    ///    (per-rule, finest-grained at the entry level).
    /// 2. ``Lint/Configuration/Rules/disabled`` accumulated across this
    ///    configuration and its parent chain (per-rule, applied wholesale
    ///    to matching IDs regardless of which layer registered them).
    ///
    /// A rule disabled at either axis is dropped from
    /// ``entries``; neither axis surfaces the rule in the engine's per-rule
    /// loop.
    public struct Effective: Sendable {
        @usableFromInline
        internal let _config: Lint.Configuration

        /// Creates the chain-resolved view over the given configuration.
        @inlinable
        public init(_config: Lint.Configuration) {
            self._config = _config
        }
    }
}

extension Lint.Configuration.Rules.Effective {
    /// Flattened rule entries with later layers overriding earlier ones.
    ///
    /// Resolution is per rule ID; disabled rules are dropped.
    @inlinable
    public var entries: [Lint.Rule.Configuration] {
        var raw: [Lint.Rule.Configuration] = []
        if let parent = _config.parent {
            raw.append(contentsOf: parent.rules.effective.entries)
        }
        raw.append(contentsOf: _config._ruleEntries)
        var byID: [Lint.Rule.ID: Lint.Rule.Configuration] = [:]
        var order: [Lint.Rule.ID] = []
        for entry in raw {
            let id = entry.rule.id
            if byID[id] == nil { order.append(id) }
            byID[id] = entry
        }
        let disabledIDs = self.disabled
        return order.compactMap { id in
            guard let entry = byID[id], entry.mode == .enabled else { return nil }
            if disabledIDs.contains(id) { return nil }
            return entry
        }
    }

    /// Walks the parent chain and accumulates every layer's disabled
    /// set into a single `Set` for `O(1)` lookup at ``entries``.
    @inlinable
    public var disabled: Set<Lint.Rule.ID> {
        var ids: Set<Lint.Rule.ID> = []
        if let parent = _config.parent {
            for id in parent.rules.effective.disabled {
                ids.insert(id)
            }
        }
        for id in _config._disabledRules {
            ids.insert(id)
        }
        return ids
    }
}
