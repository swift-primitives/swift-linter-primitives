extension Lint.Rule {

    @inlinable
    public func filtered(toPaths filter: Lint.Filter) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: self.severity.default,
            suppression: self.suppression,
            findings: { (source: borrowing Lint.Source.Parsed, severity) in
                guard filter.matches(sourcePath: source.path) else { return [] }
                return self.findings(source, severity)
            },

            fix: Self.gated(self.fix, by: filter)
        )
    }

    @inlinable
    public static func gated(
        _ fix: (@Sendable (borrowing Lint.Source.Parsed) -> Swift.String?)?,
        by filter: Lint.Filter
    ) -> (@Sendable (borrowing Lint.Source.Parsed) -> Swift.String?)? {
        guard let fix else { return nil }
        return { (source: borrowing Lint.Source.Parsed) -> Swift.String? in
            guard filter.matches(sourcePath: source.path) else { return nil }
            return fix(source)
        }
    }

    @inlinable
    public func with(default severity: Diagnostic.Severity) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: severity,
            suppression: self.suppression,
            findings: self.findings,
            fix: self.fix
        )
    }

    @inlinable
    public func pinned(to severity: Diagnostic.Severity) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: severity,
            suppression: self.suppression,
            findings: { (source: borrowing Lint.Source.Parsed, _) in
                self.findings(source, severity)
            },
            fix: self.fix
        )
    }

    @inlinable
    public static func combining(
        id: Lint.Rule.ID,
        default severity: Diagnostic.Severity,
        suppression: Lint.Rule.Suppression = .none,
        _ rules: [Lint.Rule]
    ) -> Lint.Rule {
        Lint.Rule(
            id: id,
            default: severity,
            suppression: suppression,
            findings: { (source: borrowing Lint.Source.Parsed, severity) in
                var out: [Diagnostic.Record] = []
                for rule in rules {
                    out.append(contentsOf: rule.findings(source, severity))
                }
                return out
            }
        )
    }
}
