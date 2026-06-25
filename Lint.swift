// swift-linter-tools-version: 0.1
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

// Foundation-up dogfeed. swift-linter-primitives is the L1 primitives-tier
// package that defines the public `Lint.*` engine types every rule pack
// consumes. It is not a brand-newtype-owning package (no Tagged-newtype
// recognizer reservations), so it loads the full primitives-tier bundle
// without the `.excluding(rules:)` combinator three brand-owning packages
// use to scope out same-package recognizer firings.

import Linter
import Linter_Primitives_Rules

Lint.run(dependencies: [
    .package(
        path: "../swift-primitives-linter-rules",
        products: ["Linter Primitives Rules"]
    ),
]) {
    Lint.Rule.Bundle.primitives
}
