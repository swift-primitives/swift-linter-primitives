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

public import SwiftSyntax

extension Lint {
    /// Brand-owner recognizer — the shared, syntax-only support that lets a
    /// brand-boundary rule self-suppress when the *run's own sources* declare
    /// the brand type the rule guards.
    ///
    /// ## The problem it solves
    ///
    /// The numerics-cluster rules (`raw value access`, `chained rawvalue
    /// access`, `int public parameter`, `pointer advanced by`, `bitpattern
    /// rawvalue chain`, `unchecked call site`, `zero or one literal`) plus
    /// `tagged extension public init` target a *consumer*'s access to a
    /// brand-newtype's boundary. Every one of them also fires on the
    /// brand-owner's own same-package surface, because the boundary shape
    /// (`.rawValue`, an `Int` overload, `__unchecked:` …) is
    /// legitimate-by-construction there. Before this recognizer the owner
    /// packages carried per-package `excluding(rules:)` stopgaps
    /// ([LINT-EXCLUDE-*]).
    ///
    /// ## The recognizer
    ///
    /// The engine parses every source in a run and stamps each
    /// ``Lint/Source/Parsed`` with the union of the run's namespace-root type
    /// names (``Lint/Source/Parsed/declaredTypeNames``). A rule guarding a
    /// brand asks ``owned(_:in:)`` whether the run declares that brand; if so
    /// it returns no findings for the whole run. Cross-package strict-superset
    /// firing is preserved by construction: a consumer run does not declare
    /// the brand, so the rule still fires there.
    public enum Brand {}
}

extension Lint.Brand {
    /// The canonical ecosystem numeric-brand vocabulary — the brand-newtype
    /// namespace roots whose owner packages legitimately use the numeric
    /// boundary shapes on their own surface.
    ///
    /// A run that declares (at namespace root) any of these types is the
    /// owner of that brand, so the brand-agnostic boundary rules
    /// self-suppress for the run. This single constant replaces the five
    /// per-package `excluding(rules:)` lists (cardinal / ordinal / cyclic /
    /// affine / carrier). Extend it — in this one place — when a new
    /// value-form or protocol-form brand-owner joins the cohort.
    ///
    /// `zero or one literal` is intentionally NOT driven by this vocabulary:
    /// it recognises a zero- or one-argument `Cardinal` constructor call
    /// specifically and so guards only `"Cardinal"`, keeping it firing on a
    /// stray zero-argument `Cardinal` construction written inside a
    /// *different* brand-owner (e.g. ordinal).
    public static let numericBoundaryVocabulary: Swift.Set<Swift.String> = [
        "Cardinal",
        "Ordinal",
        "Cyclic",
        "Affine",
        "Carrier",
    ]

    /// The names of namespace-root (top-level) type declarations in `tree` —
    /// `struct`, `enum`, `protocol`, `class`, `actor`.
    ///
    /// Namespace-root only: a nested type named `Cardinal` inside a consumer's
    /// own namespace does not make the consumer the brand owner. The engine
    /// unions this across every file in a run to build the run-level
    /// ``Lint/Source/Parsed/declaredTypeNames`` set.
    public static func topLevelTypeNames(in tree: SourceFileSyntax) -> Swift.Set<Swift.String> {
        var names: Swift.Set<Swift.String> = []
        for statement in tree.statements {
            let item = statement.item
            if let decl = item.as(StructDeclSyntax.self) {
                names.insert(decl.name.text)
            } else if let decl = item.as(EnumDeclSyntax.self) {
                names.insert(decl.name.text)
            } else if let decl = item.as(ProtocolDeclSyntax.self) {
                names.insert(decl.name.text)
            } else if let decl = item.as(ClassDeclSyntax.self) {
                names.insert(decl.name.text)
            } else if let decl = item.as(ActorDeclSyntax.self) {
                names.insert(decl.name.text)
            }
        }
        return names
    }

    /// True when the run's own sources declare — at namespace root — any of
    /// `brands`, i.e. the run OWNS the brand a boundary rule guards.
    ///
    /// A rule calls this at the top of its `findings` closure and returns
    /// `[]` when it is `true`. Reads the run-level set the engine stamped on
    /// `source`; an unstamped `Parsed` (empty ``Lint/Source/Parsed/declaredTypeNames``)
    /// is never owned, so the rule fires as it did before the recognizer.
    public static func owned(
        _ brands: Swift.Set<Swift.String>,
        in source: borrowing Lint.Source.Parsed
    ) -> Swift.Bool {
        !brands.isDisjoint(with: source.declaredTypeNames)
    }
}
