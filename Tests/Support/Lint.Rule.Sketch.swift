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

internal import SwiftSyntax

/// Sketch rules used to exercise the witness-shape end-to-end.
///
/// These exist in test-support, not in `Linter_Primitives`, because the
/// L1 package owns the rule namespace but ships zero rules — concrete
/// rules live in dedicated rule packs. The sketches here only prove the
/// witness API compiles and runs.
extension Lint.Rule {
    /// A trivial rule that emits one finding for every `try?` expression
    /// in the parsed tree. Mirrors what the real `try_optional` rule does
    /// in the canonical rule pack — but inlined as a witness value to
    /// demonstrate the shape.
    public static let `sketch try optional` = Lint.Rule(
        id: "sketch_try_optional",
        default: .warning,
        findings: { (source: borrowing Lint.Source.Parsed, severity) in
            final class Visitor: SyntaxVisitor {
                var hits: [SourceLocation] = []
                let converter: SourceLocationConverter
                init(converter: SourceLocationConverter) {
                    self.converter = converter
                    super.init(viewMode: .sourceAccurate)
                }
                override func visit(_ node: TryExprSyntax) -> SyntaxVisitorContinueKind {
                    if node.questionOrExclamationMark?.tokenKind == .postfixQuestionMark {
                        hits.append(node.startLocation(converter: converter))
                    }
                    return .visitChildren
                }
            }
            let visitor = Visitor(converter: source.converter)
            visitor.walk(source.tree)
            return visitor.hits.map { swiftLocation in
                Diagnostic.Record(
                    location: Source.Location(
                        fileID: source.file.fileID,
                        filePath: source.file.filePath,
                        line: swiftLocation.line,
                        column: swiftLocation.column
                    ),
                    severity: severity,
                    identifier: "sketch_try_optional",
                    message: "`try?` swallows typed-throws errors"
                )
            }
        }
    )

    /// A rule that always emits nothing — useful as a no-op control in
    /// composition tests.
    public static let `sketch noop` = Lint.Rule(
        id: "sketch_noop",
        default: .warning,
        findings: { (_: borrowing Lint.Source.Parsed, _) in [] }
    )
}
