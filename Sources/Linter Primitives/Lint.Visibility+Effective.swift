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

extension Lint.Visibility {
    /// The Swift access-control modifier on `modifiers`, considered as a
    /// declared visibility.
    ///
    /// Returns `nil` when no modifier is present (the caller decides what
    /// default to apply — typically ``internal`` at file scope, or the
    /// enclosing decl's effective visibility when walking inward).
    ///
    /// `open` collapses to ``public`` — see ``Lint/Visibility``.
    @inlinable
    public static func declared(in modifiers: DeclModifierListSyntax) -> Lint.Visibility? {
        for modifier in modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.public), .keyword(.open):
                return .public

            case .keyword(.internal):
                return .internal

            case .keyword(.fileprivate):
                return .fileprivate

            case .keyword(.private):
                return .private

            default:
                continue
            }
        }
        return nil
    }

    /// Effective visibility of `node` — the minimum of every declared
    /// access-control modifier walked from `node` up to the source-file
    /// root.
    ///
    /// Returns ``internal`` when the entire chain carries no explicit
    /// modifier (Swift's file-scope default).
    ///
    /// The walker visits `node` itself plus every enclosing decl
    /// (struct, class, enum, actor, extension, protocol, function,
    /// initializer, subscript, variable, typealias, associatedtype).
    /// Mirrors `namingHasFileprivateOrPrivateEffectiveVisibility` from
    /// the institute rule pack (Wave 3 Thread 4 amendment to
    /// [API-NAME-002]) but generalizes the return from `Bool` to the
    /// four-case enum and so is reusable beyond the compound-identifier
    /// rule.
    @inlinable
    public static func effective(of node: Syntax) -> Lint.Visibility {
        var minimum: Lint.Visibility?
        var cursor: Syntax? = node
        while let candidate = cursor {
            if let modifiers = modifiers(of: candidate),
                let declared = declared(in: modifiers)
            {
                minimum = minimum.map { Swift.min($0, declared) } ?? declared
            }
            cursor = candidate.parent
        }
        return minimum ?? .internal
    }

    @usableFromInline
    static func modifiers(of node: Syntax) -> DeclModifierListSyntax? {
        if let decl = node.as(StructDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ClassDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(EnumDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ActorDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ExtensionDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ProtocolDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(FunctionDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(InitializerDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(SubscriptDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(VariableDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(TypeAliasDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(AssociatedTypeDeclSyntax.self) { return decl.modifiers }
        return nil
    }
}
