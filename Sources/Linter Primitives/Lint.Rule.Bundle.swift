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
    /// Namespace for curated rule bundles published by tier-level rule
    /// packages.
    ///
    /// Each tier-level rule package publishes a single static property on
    /// this namespace that aggregates its own rules plus the upstream
    /// tier's bundle. Consumers reference one bundle by name — they do not
    /// hand-maintain a rule list:
    ///
    /// ```swift
    /// let configuration = Lint.Configuration {
    ///     Lint.Rule.Bundle.primitives
    /// }
    /// ```
    ///
    /// The naming mirrors the three-tier partition
    /// (`swift-institute/Research/three-tier-linter-rules-partition.md`):
    ///
    /// - `universal`  — published by `swift-linter-rules`. Universal Swift
    ///   hygiene; no institute citations in messages.
    /// - `institute`  — published by `swift-institute-linter-rules`.
    ///   Equals `universal` + institute-tier rules.
    /// - `primitives` — published by `swift-primitives-linter-rules`.
    ///   Equals `institute` + primitives-tier rules.
    ///
    /// A bundle is just `[Lint.Rule.Configuration]` — the same shape the
    /// `Lint.Configuration { … }` result builder consumes — so a consumer
    /// MAY append per-consumer overrides after expanding the bundle:
    ///
    /// ```swift
    /// let configuration = Lint.Configuration {
    ///     Lint.Rule.Bundle.primitives
    ///     Lint.Rule.Configuration.override(.`try optional`, severity: .error)
    ///     Lint.Rule.Configuration.enable(.`tagged unchecked with typed alternative`)
    /// }
    /// ```
    public enum Bundle {}
}
