extension Lint {

    public struct Rule: Sendable {

        public let id: Lint.Rule.ID

        public let severity: Severity

        public let suppression: Suppression

        public let findings:
            @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) -> [Diagnostic.Record]

        public let fix: (@Sendable (borrowing Lint.Source.Parsed) -> Swift.String?)?

        @inlinable
        public init(
            id: Lint.Rule.ID,
            default severity: Diagnostic.Severity,
            suppression: Lint.Rule.Suppression = .none,
            findings:
                @escaping @Sendable (borrowing Lint.Source.Parsed, Diagnostic.Severity) ->
                [Diagnostic.Record],
            fix: (@Sendable (borrowing Lint.Source.Parsed) -> Swift.String?)? = nil
        ) {
            self.id = id
            self.severity = Severity(default: severity)
            self.suppression = suppression
            self.findings = findings
            self.fix = fix
        }
    }
}
