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

extension Lint.Source {
    /// A parsed source file ready for rule predicates.
    ///
    /// Bundles the values every rule needs to emit findings:
    ///
    /// - ``Source/File`` — file identity (`fileID`, `filePath`); enriches
    ///   emitted ``Diagnostic_Primitives/Diagnostic/Record`` values.
    /// - ``Lint/Source/Path`` — the run-root-relative typed path emitted
    ///   by the orchestrator's walker. Carried in the bundle so that path
    ///   filtering can fold into rule witnesses
    ///   (see ``Lint/Rule/filtered(toPaths:)``).
    /// - `SourceFileSyntax` — the parsed AST (from Apple `swift-syntax`).
    /// - `SourceLocationConverter` — maps `AbsolutePosition` to (line,
    ///   column) for diagnostic emission.
    ///
    /// Rule witnesses consume the bundle directly:
    ///
    /// ```swift
    /// findings: { source, severity in
    ///     // source.file, source.path, source.tree, source.converter
    /// }
    /// ```
    public struct Parsed: ~Copyable, Sendable {
        /// File identity (`fileID`, `filePath`) emitted findings carry.
        public let file: Source.File

        /// The run-root-relative typed path of the source file.
        public let path: Lint.Source.Path

        /// The parsed abstract syntax tree, from Apple `swift-syntax`.
        public let tree: SourceFileSyntax

        /// Converts an `AbsolutePosition` to a (line, column) location.
        public let converter: SourceLocationConverter

        /// Creates a parsed-source bundle from its file identity, path,
        /// syntax tree, and location converter.
        @inlinable
        public init(
            file: Source.File,
            path: Lint.Source.Path,
            tree: SourceFileSyntax,
            converter: SourceLocationConverter
        ) {
            self.file = file
            self.path = path
            self.tree = tree
            self.converter = converter
        }
    }
}
