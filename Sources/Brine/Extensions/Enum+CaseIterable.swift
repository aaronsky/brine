
#if !swift(>=4.2)
    public protocol CaseIterable {
        associatedtype AllCases: Collection where AllCases.Element == Self
        static var allCases: AllCases { get }
    }
#endif
