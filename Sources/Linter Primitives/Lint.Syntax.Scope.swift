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

extension Lint.Syntax {
    /// Namespace for lexical-scope syntax primitives.
    public enum Scope {}
}

extension Lint.Syntax.Scope {
    /// Whether `node` sits at file (top) scope — reachable from
    /// `SourceFileSyntax` without crossing a nominal-type body,
    /// function-like body, or accessor/closure body.
    ///
    /// Walks `node.parent` upward. Returns `true` on reaching
    /// `SourceFileSyntax`; returns `false` on the first `StructDeclSyntax`,
    /// `ClassDeclSyntax`, `EnumDeclSyntax`, `ActorDeclSyntax`,
    /// `ProtocolDeclSyntax`, `ExtensionDeclSyntax`, `FunctionDeclSyntax`,
    /// `InitializerDeclSyntax`, `DeinitializerDeclSyntax`,
    /// `SubscriptDeclSyntax`, `AccessorDeclSyntax`, `AccessorBlockSyntax`,
    /// or `ClosureExprSyntax` ancestor.
    ///
    /// `IfConfigDeclSyntax` is deliberately **not** a stopper: a
    /// declaration nested only inside a file-scope `#if` is still
    /// top-level.
    ///
    /// This helper stops on `ExtensionDeclSyntax` — a type declared inside
    /// an `extension` body is not considered top-level by this predicate.
    /// A caller for which extensions are transparent (e.g. an ecosystem
    /// convention where every type is declared via `extension Parent { ... }`)
    /// must not call this bare; it should walk independently, skipping
    /// `ExtensionDeclSyntax` ancestors itself.
    @inlinable
    public static func isTopLevel(_ node: some SyntaxProtocol) -> Swift.Bool {
        var current: Syntax? = Syntax(node).parent
        while let ancestor = current {
            if ancestor.is(SourceFileSyntax.self) {
                return true
            }
            if ancestor.is(StructDeclSyntax.self)
                || ancestor.is(ClassDeclSyntax.self)
                || ancestor.is(EnumDeclSyntax.self)
                || ancestor.is(ActorDeclSyntax.self)
                || ancestor.is(ProtocolDeclSyntax.self)
                || ancestor.is(ExtensionDeclSyntax.self)
                || ancestor.is(FunctionDeclSyntax.self)
                || ancestor.is(InitializerDeclSyntax.self)
                || ancestor.is(DeinitializerDeclSyntax.self)
                || ancestor.is(SubscriptDeclSyntax.self)
                || ancestor.is(AccessorDeclSyntax.self)
                || ancestor.is(AccessorBlockSyntax.self)
                || ancestor.is(ClosureExprSyntax.self)
            {
                return false
            }
            current = ancestor.parent
        }
        return false
    }
}
