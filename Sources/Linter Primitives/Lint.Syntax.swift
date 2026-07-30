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

/// Namespace for pack-independent Swift-syntax primitives.
///
/// These predicates carry no Institute policy: their vocabulary and
/// invariants come from SwiftSyntax and the Swift grammar, not from any
/// Institute rule. They were consolidated here (rather than left as
/// per-pack copies) because L3 rule packs had independently reimplemented
/// them, and one copy had already drifted from the others. See
/// `swift-foundations/swift-institute-linter-rules#17`.
extension Lint {
    /// See the type-level doc above.
    public enum Syntax {}
}
