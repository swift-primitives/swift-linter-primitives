extension Lint {

    public struct Rule: Sendable {

        public let id: Lint.Rule.ID

        public let severity: Severity

        public let suppression: Suppression

        public let observe:
            @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) -> Observation

        public let repair:
            @Sendable (borrowing Lint.Source.Parsed) -> Repair.Proposal

        @inlinable
        public init(
            id: Lint.Rule.ID,
            default severity: Diagnostic.Severity,
            suppression: Lint.Rule.Suppression = .none,
            observe:
                @escaping @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) ->
                Observation,
            repair:
                @escaping @Sendable (borrowing Lint.Source.Parsed) -> Repair.Proposal = {
                    _ in .refused(.repairUnavailable)
                }
        ) {
            self.id = id
            self.severity = Severity(default: severity)
            self.suppression = suppression
            self.observe = observe
            self.repair = repair
        }

        @inlinable
        public static func measured(
            _ findings:
                @escaping @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) ->
                [Diagnostic.Record]
        ) -> @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) -> Observation {
            { source, severity in
                Observation(findings: findings(source, severity), coverage: .measured)
            }
        }
    }
}
