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

public import Ownership_Immutable_Primitives
public import Standard_Library_Extensions

extension Lint {
    /// A linter configuration value, the centerpiece of the typed
    /// `Lint.swift` DSL.
    ///
    /// The configuration composes per-rule entries
    /// (``Lint/Rule/Configuration``) plus optional parent inheritance and an
    /// excluded-paths list. Construction uses
    /// ``Standard_Library_Extensions/Array/Builder`` for the rules block —
    /// declarative, control-flow-friendly, no bespoke result-builder needed.
    /// Rule-related leaves are surfaced via the ``rules`` Property.View
    /// accessor (``Lint/Configuration/Rules``): per-layer entries and
    /// disabled IDs at ``rules/entries`` / ``rules/disabled``; chain-resolved
    /// versions at ``rules/effective``.
    ///
    /// ```swift
    /// import Linter_Primitives
    ///
    /// let configuration = Lint.Configuration(
    ///     excluded: ["Tests/Fixtures", ".build"]
    /// ) {
    ///     .enable(.`unchecked call site`)
    ///     .override(.`try optional`, severity: .error)
    /// }
    /// ```
    public struct Configuration: Sendable {
        /// Recursive parent storage via the institute's shared-ownership
        /// primitive.
        ///
        /// `Configuration?` cannot directly hold itself (value-type
        /// recursion); `Ownership.Immutable` indirects the storage on the heap
        /// with ARC semantics — multiple readers (each ``rules/effective``
        /// walk traverses the chain) without allocation per traversal.
        @usableFromInline
        internal let _parent: Ownership.Immutable<Lint.Configuration>?

        /// Per-rule entries authored at this configuration layer.
        ///
        /// Surfaced via ``rules/entries``.
        @usableFromInline
        internal let _ruleEntries: [Lint.Rule.Configuration]

        /// Typed path-prefix entries excluded ecosystem-wide from linting at
        /// this layer.
        ///
        /// The walker also has its own structural exclusions (`.build/`,
        /// `Carthage/`, etc.); this list adds package-specific extras (e.g.,
        /// `Tests/Fixtures`). Typed via ``Lint/Filter/Prefix`` so the
        /// rule-domain identity is carried at compile time, matching the
        /// per-rule ``Lint/Filter/included`` / ``Lint/Filter/excluded`` shape.
        public let excluded: [Lint.Filter.Prefix]

        /// Rule IDs disabled wholesale at this configuration layer.
        ///
        /// Surfaced via ``rules/disabled``.
        ///
        /// Companion to per-line `// swift-linter:disable:next <id>`
        /// directives (decision 2026-05-11, hybrid line-comment +
        /// config-file). The two axes serve categorically different
        /// scopes: a per-line directive elides a single finding at a
        /// known site; the disabled set withdraws the entire rule from
        /// the effective set for this configuration layer.
        ///
        /// Honored at ``rules/effective``: any entry whose rule ID
        /// appears in this layer's (or any inherited layer's) disabled
        /// set is dropped from the result, mirroring the per-entry
        /// ``Lint/Rule/Configuration/Mode/disabled`` short-circuit.
        @usableFromInline
        internal let _disabledRules: Set<Lint.Rule.ID>

        /// Creates a configuration layer from an optional parent, excluded
        /// paths, disabled rule IDs, and a rules block.
        @inlinable
        public init(
            inheriting parent: Self? = nil,
            excluded: [Lint.Filter.Prefix] = [],
            disabled: Set<Lint.Rule.ID> = [],
            @Array<Lint.Rule.Configuration>.Builder rules: () -> [Lint.Rule.Configuration]
        ) {
            self._parent = parent.map(Ownership.Immutable.init)
            self._ruleEntries = rules()
            self.excluded = excluded
            self._disabledRules = disabled
        }
    }
}

extension Lint.Configuration {
    /// Optional parent configuration to inherit from.
    ///
    /// The effective rule set composes the parent's entries first, then this
    /// configuration's entries (later entries override earlier ones for the
    /// same rule ID).
    @inlinable
    public var parent: Lint.Configuration? {
        _parent.map(\.value)
    }

    /// Empty configuration — no rules fire, no exclusions, no parent.
    public static let empty: Lint.Configuration = Lint.Configuration { [] }

    /// Property.View accessor for rule-related leaves.
    ///
    /// - ``Lint/Configuration/Rules/entries`` — entries authored at this
    ///   configuration layer.
    /// - ``Lint/Configuration/Rules/disabled`` — IDs disabled at this
    ///   configuration layer.
    /// - ``Lint/Configuration/Rules/effective`` — chain-resolved sub-view
    ///   (entries + disabled across the parent chain).
    @inlinable
    public var rules: Rules { Rules(_config: self) }
}
