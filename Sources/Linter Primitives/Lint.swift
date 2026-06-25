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
/// the rule witness value, the finding record, and the rule activation
/// configuration. Concrete rule implementations, filesystem walking, output
/// formatting, and orchestration are L3 concerns and live in
/// `swift-foundations/swift-linter` (the orchestrating binary) and
/// `swift-foundations/swift-linter-rules` (the canonical rule pack).
///
/// ## Layered architecture
///
/// - **L1 swift-linter-primitives** (this package) — pure types/protocols.
///   Composes `swift-source-primitives` (Source.File, Source.Location),
///   `swift-diagnostic-primitives` (Diagnostic.Severity, Diagnostic.Record),
///   `swift-cardinal-primitives`, `swift-tagged-primitives`,
///   `swift-ownership-primitives`, `swift-standard-library-extensions`, and
///   Apple `swift-syntax`.
/// - **L3 swift-linter-rules** — concrete rule pack (each rule is a static
///   ``Lint/Rule`` witness value); ships independent of the engine.
/// - **L3 swift-linter** — orchestrating binary: filesystem walker,
///   typed-DSL `Lint.swift` configuration loader, terminal/SARIF reporters,
///   run orchestrator, CLI executable. Engine ships rule-pack-agnostic;
///   consumers compose engine + rule packs in a `Lint/` nested SwiftPM
///   package or via direct ``Lint/Configuration`` construction.
public enum Lint {}
