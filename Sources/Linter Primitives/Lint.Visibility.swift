extension Lint {

    public enum Visibility: Swift.String, Sendable, Hashable, Codable, Comparable, CaseIterable {
        case `public`
        case `internal`
        case `fileprivate`
        case `private`
    }
}

extension Lint.Visibility {

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.ordinal < rhs.ordinal
    }

    @inlinable
    public var ordinal: Swift.Int {
        switch self {
        case .public: return 3
        case .internal: return 2
        case .fileprivate: return 1
        case .private: return 0
        }
    }
}
