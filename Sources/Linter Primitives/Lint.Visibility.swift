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
    /// Effective Swift access-level visibility of the declaration enclosing a
    /// diagnostic's source location.
    ///
    /// Captured per-finding by the engine so empirical follow-ups (e.g.,
    /// Thread 4 fileprivate/private slice ecosystem-wide) can segment
    /// findings without re-walking source trees. The four cases mirror
    /// Swift's access-control levels at the granularity rules need; `open`
    /// collapses to ``public`` (the lint rules that care about visibility
    /// treat `open` and `public` identically — both are consumer-observable
    /// surface).
    ///
    /// Effective visibility is the minimum of the declaration's own
    /// modifier and every enclosing-type modifier walked from the
    /// declaration up to the source-file root. A `let` field with no
    /// explicit modifier inside `fileprivate struct Header { ... }` is
    /// effectively ``fileprivate`` — the walker that computes this lives
    /// in the engine (``Lint/Source/Parsed/visibility(at:)``) and consumes
    /// values of this enum.
    public enum Visibility: Swift.String, Sendable, Hashable, Codable, Comparable, CaseIterable {
        case `public`
        case `internal`
        case `fileprivate`
        case `private`
    }
}

extension Lint.Visibility {
    /// Orders visibilities from narrowest to widest by ``ordinal``.
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.ordinal < rhs.ordinal
    }

    /// Narrower visibilities sort lower so `min`/`max` over a chain of
    /// enclosing modifiers yields the effective access level.
    @inlinable
    public var ordinal: Swift.Int {
        switch self {
        case .public: return 3
        case .internal: return 2
        case .fileprivate: return 1
        case .private: return 0
        }
    }
}
