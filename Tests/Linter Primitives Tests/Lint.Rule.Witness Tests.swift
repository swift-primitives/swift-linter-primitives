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

import Byte_Primitives
import Linter_Primitives_Test_Support
import SwiftParser
import SwiftSyntax
import Testing

extension Lint.Rule {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension Lint.Rule.Test.Unit {
    /// Build a parsed source bundle from inline Swift source text.
    private func parsedSource(
        _ text: Swift.String,
        path: Lint.Source.Path = "Sources/Test/Test.swift"
    ) -> Lint.Source.Parsed {
        let tree = Parser.parse(source: text)
        let converter = SourceLocationConverter(fileName: "Test.swift", tree: tree)
        var manager = Source.Manager()
        let id = manager.register(
            fileID: "TestModule/Test.swift",
            filePath: "Test.swift",
            content: text.utf8.map(Byte.init)
        )
        return Lint.Source.Parsed(
            file: manager.file(for: id),
            path: path,
            tree: tree,
            converter: converter
        )
    }

    @Test
    func `Witness rule emits findings for matching syntax`() {
        let source = parsedSource(
            """
            func f() {
                _ = try? doWork()
            }
            """
        )
        let findings = Lint.Rule.`sketch try optional`.findings(source, .warning)
        #expect(findings.count == 1)
        #expect(findings.first?.identifier == "sketch_try_optional")
        #expect(findings.first?.severity == .warning)
    }

    @Test
    func `Engine threads resolved severity through the witness closure`() {
        let source = parsedSource("_ = try? f()")
        let asError = Lint.Rule.`sketch try optional`.findings(source, .error)
        #expect(asError.first?.severity == .error)
        let asWarning = Lint.Rule.`sketch try optional`.findings(source, .warning)
        #expect(asWarning.first?.severity == .warning)
    }

    @Test
    func `with default replaces only the default, not the threaded severity`() {
        let original = Lint.Rule.`sketch try optional`
        let promoted = original.with(default: .error)
        #expect(promoted.id == original.id)
        #expect(promoted.severity.default == .error)
        #expect(original.severity.default == .warning)
    }

    @Test
    func `pinned to ignores the threaded severity`() {
        let source = parsedSource("_ = try? f()")
        let pinned = Lint.Rule.`sketch try optional`.pinned(to: .error)
        let findings = pinned.findings(source, .warning)  // engine threads warning…
        #expect(findings.first?.severity == .error)  // …but rule pins error
    }

    @Test
    func `combining concatenates findings from child rules in order`() {
        let source = parsedSource("_ = try? f()")
        let composite = Lint.Rule.combining(
            id: "composite",
            default: .warning,
            [Lint.Rule.`sketch try optional`, Lint.Rule.`sketch try optional`]
        )
        let findings = composite.findings(source, .warning)
        #expect(findings.count == 2)
    }

    @Test
    func `filtered admits matching paths and short circuits non-matching`() {
        let inside = parsedSource("_ = try? f()", path: "Sources/A/x.swift")
        let outside = parsedSource("_ = try? f()", path: "Sources/B/y.swift")
        let scoped = Lint.Rule.`sketch try optional`.filtered(toPaths: .including(["Sources/A"]))
        #expect(scoped.findings(inside, .warning).count == 1)
        #expect(scoped.findings(outside, .warning).count == 0)
    }

    @Test
    func `Configuration carries the witness by value, not by metatype`() {
        let entry = Lint.Rule.Configuration.enable(.`sketch try optional`)
        #expect(entry.rule.id == "sketch_try_optional")
        #expect(entry.mode == .enabled)
        #expect(entry.severity == nil)
    }

    @Test
    func `Configuration override factory pins severity at the configuration layer`() {
        let entry = Lint.Rule.Configuration.override(.`sketch try optional`, severity: .error)
        #expect(entry.rule.id == "sketch_try_optional")
        #expect(entry.mode == .enabled)
        #expect(entry.severity == .error)
    }

    @Test
    func `enable with paths folds filter into the stored witness`() {
        let entry = Lint.Rule.Configuration.enable(
            .`sketch try optional`,
            paths: .including(["Sources/A"])
        )
        let inside = parsedSource("_ = try? f()", path: "Sources/A/x.swift")
        let outside = parsedSource("_ = try? f()", path: "Sources/B/y.swift")
        // The stored witness IS the filtered rule — engine just calls it.
        #expect(entry.rule.findings(inside, .warning).count == 1)
        #expect(entry.rule.findings(outside, .warning).count == 0)
    }

    @Test
    func `rules effective resolves severity from configuration entry`() {
        let config = Lint.Configuration {
            [
                .enable(.`sketch try optional`, severity: .error)
            ]
        }
        let effective = config.rules.effective.entries
        #expect(effective.count == 1)
        #expect(effective.first?.rule.id == "sketch_try_optional")
        #expect(effective.first?.severity == .error)
    }
}
