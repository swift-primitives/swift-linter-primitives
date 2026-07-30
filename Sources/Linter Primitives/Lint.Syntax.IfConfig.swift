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
    /// Namespace for `#if` (conditional-compilation) flattening primitives.
    ///
    /// A rule that enumerates file-scope statements or a type's members by
    /// hand drops anything nested inside a top-level `#if`/`#elseif`/`#else`
    /// clause. These primitives splice every clause's contents back into
    /// the enumeration, recursively, so a rule that walks their result sees
    /// a `#if`-guarded declaration exactly as it would see an unguarded one.
    public enum IfConfig {}
}

extension Lint.Syntax.IfConfig {
    /// Flattens `statements`, splicing every `#if` clause's statements in.
    ///
    /// Recursive: a `#if` nested inside a `#if` is flattened all the way
    /// down. Non-`#if` items are kept as-is, in order.
    @inlinable
    public static func statements(
        _ list: CodeBlockItemListSyntax
    ) -> [CodeBlockItemSyntax] {
        var result: [CodeBlockItemSyntax] = []
        for item in list {
            guard case .decl(let decl) = item.item,
                let ifConfig = decl.as(IfConfigDeclSyntax.self)
            else {
                result.append(item)
                continue
            }
            for clause in ifConfig.clauses {
                guard let elements = clause.elements?.as(CodeBlockItemListSyntax.self) else {
                    continue
                }
                result.append(contentsOf: statements(elements))
            }
        }
        return result
    }

    /// The member-block analogue of ``statements(_:)``: for each item in
    /// `block.members` whose `.decl` is an `IfConfigDeclSyntax`, splices in
    /// every clause's members recursively; every other member is kept as-is,
    /// in order.
    @inlinable
    public static func members(
        _ block: MemberBlockSyntax
    ) -> [MemberBlockItemSyntax] {
        members(block.members)
    }

    /// Overload operating directly on a `MemberBlockItemListSyntax`, for
    /// callers that already hold one (e.g. recursion, or a caller that does
    /// not have the enclosing `MemberBlockSyntax`).
    @inlinable
    public static func members(
        _ list: MemberBlockItemListSyntax
    ) -> [MemberBlockItemSyntax] {
        var result: [MemberBlockItemSyntax] = []
        for item in list {
            guard let ifConfig = item.decl.as(IfConfigDeclSyntax.self) else {
                result.append(item)
                continue
            }
            for clause in ifConfig.clauses {
                guard let elements = clause.elements?.as(MemberBlockItemListSyntax.self) else {
                    continue
                }
                result.append(contentsOf: members(elements))
            }
        }
        return result
    }
}
