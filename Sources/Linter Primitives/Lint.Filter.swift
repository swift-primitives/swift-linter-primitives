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

extension Lint {
    /// A scope filter for a configured rule.
    ///
    /// ``included`` whitelists a rule onto specific path prefixes;
    /// ``excluded`` removes path prefixes from the rule's scope. Empty
    /// arrays mean "no constraint on this side".
    ///
    /// ``Filter/all`` is the no-op default — include nothing-specific,
    /// exclude nothing — applies the rule to every path.
    ///
    /// ## Enforcement contract
    ///
    /// Filtering applies to source-file paths using **prefix-match
    /// semantics** (``Filter/matches(sourcePath:)`` ultimately calls
    /// `Swift.String.hasPrefix`):
    ///
    /// - When ``included`` is non-empty, a source path matches only if
    ///   it starts with at least one entry's underlying string.
    /// - When ``excluded`` is non-empty, a source path matches only if
    ///   it does not start with any entry's underlying string.
    /// - When both are empty (the default ``Filter/all`` shape), every
    ///   source path matches.
    ///
    /// The match is character-prefix, not path-component-prefix: an
    /// entry of `Sources/A` prefix-matches both `Sources/A/x.swift`
    /// (intended) and `Sources/Aaa/x.swift` (a known limitation per the
    /// existing ``Lint/Source/Walker/excluded`` shape). Authors
    /// disambiguate by including a trailing path separator
    /// (`Sources/A/`) at the entry edge when component-precision is
    /// required.
    ///
    /// Filter entries should align with how source paths are emitted by
    /// the orchestrator's walker: when the linter is invoked with
    /// run-root `R`, source paths are emitted as `R/<sub>/<file>.swift`,
    /// so a meaningful filter entry takes the same `R/<sub>` form.
    public struct Filter: Sendable, Hashable {
        /// Path prefixes the rule is restricted to; empty means no
        /// inclusion constraint.
        public let included: [Prefix]

        /// Path prefixes removed from the rule's scope; empty means no
        /// exclusion constraint.
        public let excluded: [Prefix]

        /// Creates a filter from its included and excluded prefix lists.
        @inlinable
        public init(included: [Prefix] = [], excluded: [Prefix] = []) {
            self.included = included
            self.excluded = excluded
        }
    }
}

extension Lint.Filter {
    /// A path-prefix entry — typed as `Tagged<Lint.Filter,
    /// Swift.String>` so the rule-domain identity is carried at
    /// compile time.
    ///
    /// The phantom tag rejects accidental mixing with file IDs, manifest
    /// paths, or other String-shaped identifiers without runtime cost.
    ///
    /// Construction via the `ExpressibleByStringLiteral`
    /// conformance shipped by `swift-tagged-primitives`'s
    /// standard-library-integration target:
    ///
    /// ```swift
    /// let prefix: Lint.Filter.Prefix = "Sources/A"
    /// Lint.Rule.Configuration.enable(
    ///     SomeRule.self,
    ///     paths: .including(["Sources/A", "Sources/B"])
    /// )
    /// ```
    public typealias Prefix = Tagged<Lint.Filter, Swift.String>

    /// No constraints — applies to every path.
    public static let all: Lint.Filter = Lint.Filter()

    /// Restricts the rule to the given path prefixes.
    @inlinable
    public static func including(_ paths: [Prefix]) -> Lint.Filter {
        Lint.Filter(included: paths)
    }

    /// Removes the given path prefixes from the rule's scope.
    @inlinable
    public static func excluding(_ paths: [Prefix]) -> Lint.Filter {
        Lint.Filter(excluded: paths)
    }

    /// Whether the filter admits a source-file path.
    ///
    /// Returns `true` when the path satisfies both the ``included``
    /// constraint (if any) and the ``excluded`` constraint (if any),
    /// per the prefix-match contract documented on ``Filter``.
    ///
    /// - Parameter sourcePath: The typed path of the source file
    ///   under consideration, in whatever form the orchestrator's
    ///   walker emits (run-root-relative; see the contract above).
    ///   Both sides of the prefix predicate are typed at the call
    ///   site (`Lint.Source.Path` haystack / `Lint.Filter.Prefix`
    ///   needle); the boundary unwrap to `Swift.String` lives in
    ///   this method's body per [IMPL-010] (`underlying`-access at
    ///   the typed-system bottom-out where `Swift.String.hasPrefix`
    ///   is invoked).
    /// - Returns: `true` when the rule should be invoke for the
    ///   path; `false` when the filter excludes it.
    @inlinable
    public func matches(sourcePath: Lint.Source.Path) -> Swift.Bool {
        let pathString = sourcePath.underlying
        if !included.isEmpty {
            var anyIncluded = false
            for prefix in included where pathString.hasPrefix(prefix.underlying) {
                anyIncluded = true
                break
            }
            if !anyIncluded { return false }
        }
        for prefix in excluded where pathString.hasPrefix(prefix.underlying) {
            return false
        }
        return true
    }
}
