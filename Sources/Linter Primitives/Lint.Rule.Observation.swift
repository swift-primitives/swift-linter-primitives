extension Lint.Rule {

    public struct Observation: Sendable, Equatable {

        public let findings: [Diagnostic.Record]

        public let coverage: Coverage

        public let applicable: Swift.Bool

        @inlinable
        public init(
            findings: [Diagnostic.Record],
            coverage: Coverage,
            applicable: Swift.Bool = true
        ) {
            self.findings = findings
            self.coverage = coverage
            self.applicable = applicable
        }
    }
}
