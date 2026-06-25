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

import Linter_Primitives_Test_Support
import Testing

extension Lint.Finding {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension Lint.Finding.Test.Unit {
    /// Build a small fixture record for tests.
    ///
    /// The exact contents don't matter; only the wrapper's pass-through and
    /// visibility-pairing behavior is under test.
    private static func fixtureRecord(
        identifier: Swift.String = "fixture rule",
        line: Swift.Int = 1,
        column: Swift.Int = 1
    ) -> Diagnostic.Record {
        Diagnostic.Record(
            location: Source.Location(
                fileID: "Module/Fixture.swift",
                filePath: "/tmp/Fixture.swift",
                line: line,
                column: column
            ),
            severity: .warning,
            identifier: identifier,
            message: "fixture finding"
        )
    }

    @Test
    func `Default visibility is nil when not supplied`() {
        let finding = Lint.Finding(record: Self.fixtureRecord())
        #expect(finding.visibility == nil)
    }

    @Test
    func `Explicit visibility is preserved`() {
        let finding = Lint.Finding(
            record: Self.fixtureRecord(),
            visibility: .private
        )
        #expect(finding.visibility == .private)
    }

    @Test
    func `Record passes through unchanged`() {
        let record = Self.fixtureRecord(identifier: "rule x", line: 42, column: 7)
        let finding = Lint.Finding(record: record, visibility: .fileprivate)
        #expect(finding.record == record)
        #expect(finding.record.identifier == "rule x")
        #expect(finding.record.location.line == 42)
        #expect(finding.record.location.column == 7)
    }

    @Test
    func `Equal records with equal visibility are equal`() {
        let a = Lint.Finding(record: Self.fixtureRecord(), visibility: .public)
        let b = Lint.Finding(record: Self.fixtureRecord(), visibility: .public)
        #expect(a == b)
    }

    @Test
    func `Equal records with different visibility are not equal`() {
        let a = Lint.Finding(record: Self.fixtureRecord(), visibility: .public)
        let b = Lint.Finding(record: Self.fixtureRecord(), visibility: .private)
        #expect(a != b)
    }

    @Test
    func `Hashable distinguishes findings by visibility`() {
        let a = Lint.Finding(record: Self.fixtureRecord(), visibility: .internal)
        let b = Lint.Finding(record: Self.fixtureRecord(), visibility: .fileprivate)
        var set: Set<Lint.Finding> = []
        set.insert(a)
        set.insert(b)
        #expect(set.count == 2)
    }

    @Test
    func `nil visibility round-trips through Hashable container`() {
        let finding = Lint.Finding(record: Self.fixtureRecord())
        var set: Set<Lint.Finding> = []
        set.insert(finding)
        #expect(set.contains(finding))
    }
}
