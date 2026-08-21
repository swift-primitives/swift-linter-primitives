extension Lint.Rule {

    @inlinable
    public func filtered(toPaths filter: Lint.Filter) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: self.severity.default,
            suppression: self.suppression,
            observe: { (source: borrowing Lint.Source.Parsed, severity) in
                guard filter.matches(sourcePath: source.path) else {
                    return Lint.Rule.Observation(
                        findings: [],
                        coverage: .measured,
                        applicable: false
                    )
                }
                return self.observe(source, severity)
            },
            repair: { (source: borrowing Lint.Source.Parsed) in
                guard filter.matches(sourcePath: source.path) else { return .unchanged }
                return self.repair(source)
            }
        )
    }

    @inlinable
    public func with(default severity: Diagnostic.Severity) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: severity,
            suppression: self.suppression,
            observe: self.observe,
            repair: self.repair
        )
    }

    @inlinable
    public func pinned(to severity: Diagnostic.Severity) -> Lint.Rule {
        Lint.Rule(
            id: self.id,
            default: severity,
            suppression: self.suppression,
            observe: { (source: borrowing Lint.Source.Parsed, _) in
                self.observe(source, severity)
            },
            repair: self.repair
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
            observe: { (source: borrowing Lint.Source.Parsed, severity) in
                var out: [Diagnostic.Record] = []
                var applicable = false
                for rule in rules {
                    let observation = rule.observe(source, severity)
                    applicable = applicable || observation.applicable
                    out.append(contentsOf: observation.findings)
                    if case .unmeasured(let reason) = observation.coverage {
                        return Lint.Rule.Observation(
                            findings: out,
                            coverage: .unmeasured(reason),
                            applicable: applicable
                        )
                    }
                }
                return Lint.Rule.Observation(
                    findings: out,
                    coverage: .measured,
                    applicable: applicable
                )
            }
        )
    }
}
