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

extension Lint.Configuration {
    /// Errors raised by typed-DSL configuration loading paths — the
    /// orchestrator's pre-evaluation check (file presence) and the
    /// post-evaluation translation from ``Lint/Manifest`` to a runtime
    /// ``Lint/Configuration`` (bad rule ID at the manifest layer, etc.).
    public enum Error: Swift.Error, Hashable, Sendable {
        case fileNotReadable(path: Swift.String)
        case malformed(path: Swift.String, reason: Swift.String)
        case unknownRuleID(Lint.Rule.ID, path: Swift.String)
    }
}
