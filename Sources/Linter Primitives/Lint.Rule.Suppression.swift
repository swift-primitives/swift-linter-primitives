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
    /// The inline-suppression directive shapes a rule sanctions.
    ///
    /// A rule must opt in to each shape explicitly. The closed policy can
    /// represent neither shape, either individual shape, or both shapes
    /// without string identifiers or an engine-owned lookup table.
    ///
    /// ```swift
    /// let rule = Lint.Rule(
    ///     id: "typed throws",
    ///     default: .error,
    ///     suppression: .next,
    ///     findings: { _, _ in [] }
    /// )
    ///
    /// rule.suppression.sanctions(.next)  // true
    /// ```
    ///
    /// This package owns declaration only. The `swift-linter` engine owns
    /// scanning directives and consulting this policy before eliding a
    /// finding.
    public struct Suppression: Sendable, Equatable {
        @usableFromInline
        internal let _next: Bool

        @usableFromInline
        internal let _line: Bool

        @usableFromInline
        internal init(next: Bool, line: Bool) {
            self._next = next
            self._line = line
        }
    }
}

extension Lint.Rule.Suppression {
    /// Sanctions no inline-suppression directive shape.
    public static let none = Self(next: false, line: false)

    /// Sanctions only `disable:next`.
    public static let next = Self(next: true, line: false)

    /// Sanctions only `disable:line`.
    public static let line = Self(next: false, line: true)

    /// Sanctions both `disable:next` and `disable:line`.
    public static let both = Self(next: true, line: true)

    /// Returns whether this policy sanctions `directive`.
    public func sanctions(_ directive: Directive) -> Bool {
        switch directive {
        case .next:
            _next
        case .line:
            _line
        }
    }
}
