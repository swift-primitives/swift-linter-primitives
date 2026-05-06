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
    /// Errors raised when reading or parsing a `.swift-primitives-lint.yml`
    /// (or equivalent) config file.
    public enum Error: Swift.Error, Hashable, Sendable {
        case fileNotReadable(path: Swift.String)
        case malformed(path: Swift.String, reason: Swift.String)
        case unknownRuleID(Swift.String, path: Swift.String)
    }
}
