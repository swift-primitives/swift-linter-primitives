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

import Testing
import Linter_Primitives_Test_Support

extension Lint.Finding {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension Lint.Finding.Test.Unit {
    @Test
    func `Finding stores location severity ruleID and message`() {
        let location = Source.Location(
            fileID: "Module/File.swift",
            filePath: "/abs/Module/File.swift",
            line: 42,
            column: 7
        )
        let finding = Lint.Finding(
            location: location,
            severity: .warning,
            ruleID: "unchecked_call_site",
            message: "test"
        )
        #expect(finding.location == location)
        #expect(finding.severity == .warning)
        #expect(finding.ruleID == "unchecked_call_site")
        #expect(finding.message == "test")
    }

    @Test
    func `Findings sort by location then severity then ruleID`() {
        let earlier = Source.Location(fileID: "A", line: 1, column: 1)
        let later = Source.Location(fileID: "A", line: 5, column: 1)
        let a = Lint.Finding(location: earlier, severity: .warning, ruleID: "r1", message: "m")
        let b = Lint.Finding(location: later, severity: .error, ruleID: "r1", message: "m")
        #expect(a < b)
    }
}

extension Lint.Configuration {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension Lint.Configuration.Test.Unit {
    @Test
    func `isActivated returns true for known rule ID`() {
        let config = Lint.Configuration(activatedRuleIDs: ["unchecked_call_site"])
        #expect(config.isActivated("unchecked_call_site"))
    }

    @Test
    func `isActivated returns false for unknown rule ID`() {
        let config = Lint.Configuration(activatedRuleIDs: ["unchecked_call_site"])
        #expect(!config.isActivated("some_other_rule"))
    }

    @Test
    func `Empty configuration activates no rules`() {
        let config = Lint.Configuration.empty
        #expect(config.activatedRuleIDs.isEmpty)
    }
}
