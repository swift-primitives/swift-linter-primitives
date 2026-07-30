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

extension Lint.Syntax {
    /// Namespace for identifier-token-level syntax primitives.
    public enum Identifier {}
}

extension Lint.Syntax.Identifier {
    /// Strips a single matched pair of surrounding backticks from `text`.
    ///
    /// The **matched-pair** contract: both a leading and a trailing
    /// backtick must be present, or `text` is returned unchanged. A
    /// one-sided stray backtick (only a leading or only a trailing one)
    /// is left untouched — it is not an escaped identifier.
    ///
    /// Operates on a *single* identifier token's `.text`. Never call this
    /// on a dotted path (`A.B.C`) — each segment must be unescaped
    /// individually.
    @inlinable
    public static func unescaped(_ text: Swift.String) -> Swift.String {
        guard text.count >= 2, text.hasPrefix("`"), text.hasSuffix("`") else { return text }
        return Swift.String(text.dropFirst().dropLast())
    }
}
