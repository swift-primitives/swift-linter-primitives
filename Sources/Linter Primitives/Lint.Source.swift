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
    /// Source-handling namespace inside `Lint`.
    ///
    /// Concrete types nest as `Lint.Source.X` (e.g.,
    /// ``Lint/Source/Parsed``). The L3 swift-linter package extends this
    /// namespace with filesystem-walking and orchestration types
    /// (`Lint.Source.Walker`).
    public enum Source {}
}

extension Lint.Source {
    /// A typed source-file path emitted by the orchestrator's walker.
    ///
    /// Distinct phantom-tag from ``Lint/Filter/Prefix`` (prefix-pattern
    /// shape vs source-path shape — semantically different roles, same
    /// underlying string). Carrying the tag lets the prefix-match
    /// boundary (``Lint/Filter/matches(sourcePath:)``) state its
    /// asymmetric contract directly in the type system: a
    /// `Lint.Source.Path` is the haystack; a `Lint.Filter.Prefix` is
    /// the needle.
    public typealias Path = Tagged<Lint.Source, Swift.String>
}
