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

/// Namespace for linter primitives.
///
/// `Lint` provides the framework-level abstractions a linter is built from:
/// the rule capability protocol, the finding record, and the rule activation
/// configuration. Concrete rule implementations, filesystem walking, output
/// formatting, and orchestration are L3 concerns and live in
/// `swift-foundations/swift-linter`.
///
/// ## Layered architecture
///
/// - **L1 swift-linter-primitives** (this package) — pure types/protocols.
///   Composes `swift-source-primitives` (Source.File, Source.Location),
///   `swift-diagnostic-primitives` (Diagnostic.Severity), `swift-cardinal-primitives`,
///   `swift-tagged-primitives`, and Apple `swift-syntax`.
/// - **L3 swift-linter** — composed tool: filesystem walker, YAML config
///   loader, terminal/SARIF reporters, run orchestrator, concrete rules
///   (e.g., `Lint.Rule.Unchecked` for R5), CLI executable.
public enum Lint {}
