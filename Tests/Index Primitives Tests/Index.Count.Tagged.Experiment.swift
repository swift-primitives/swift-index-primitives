// ===----------------------------------------------------------------------===//
//
// EXPERIMENT: Validate Index.Count as Tagged Typealias
//
// This test validates the proposed restructuring of Index.Count from a nested
// struct to a Tagged typealias. See Research/index-count-offset-as-tagged.md
//
// ===----------------------------------------------------------------------===//

import Testing
@testable import Index_Primitives

// MARK: - Simulated Tagged Count (parallel type for testing)

/// A prototype of Index.Count as a Tagged typealias.
/// If this works, we can migrate the real Index.Count.
typealias ExperimentalCount<Tag: ~Copyable> = Tagged<Tag, Cardinal.Count>

// MARK: - API Compatibility Extensions
// Note: No @inlinable in test code - those would be added in the real implementation

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {

    /// Creates a typed count from an unsigned integer (prototype).
    init(experimentUInt rawValue: UInt) {
        self.init(__unchecked: (), Cardinal.Count(rawValue))
    }

    /// Creates a typed count from a signed integer (prototype).
    init(experimentInt rawValue: Int) throws(Cardinal.Count.Error) {
        self.init(__unchecked: (), try Cardinal.Count(rawValue))
    }

    /// The zero count (prototype).
    static var experimentZero: Self {
        Self(__unchecked: (), Cardinal.Count.zero)
    }

    /// The count of one (prototype).
    static var experimentOne: Self {
        Self(__unchecked: (), Cardinal.Count.one)
    }

    /// Prototype addition.
    static func experimentAdd(_ lhs: Self, _ rhs: Self) -> Self {
        Self(__unchecked: (), lhs.rawValue + rhs.rawValue)
    }
}

// MARK: - Validation Tests

@Suite("Index.Count Tagged Experiment")
struct IndexCountTaggedExperiment {

    @Test("Construction from UInt")
    func constructionUInt() {
        let count = ExperimentalCount<Int>(experimentUInt: 42)
        #expect(count.rawValue.rawValue == 42)
    }

    @Test("Construction from Int")
    func constructionInt() throws {
        let count = try ExperimentalCount<Int>(experimentInt: 42)
        #expect(count.rawValue.rawValue == 42)
    }

    @Test("Construction from negative Int throws")
    func constructionNegativeThrows() {
        #expect(throws: Cardinal.Count.Error.self) {
            _ = try ExperimentalCount<Int>(experimentInt: -1)
        }
    }

    @Test("Static constants")
    func staticConstants() {
        #expect(ExperimentalCount<Int>.experimentZero.rawValue.rawValue == 0)
        #expect(ExperimentalCount<Int>.experimentOne.rawValue.rawValue == 1)
    }

    @Test("Equality (free from Tagged)")
    func equality() {
        let a = ExperimentalCount<Int>(experimentUInt: 5)
        let b = ExperimentalCount<Int>(experimentUInt: 5)
        let c = ExperimentalCount<Int>(experimentUInt: 10)

        #expect(a == b)
        #expect(a != c)
    }

    @Test("Comparison (free from Tagged)")
    func comparison() {
        let small = ExperimentalCount<Int>(experimentUInt: 5)
        let large = ExperimentalCount<Int>(experimentUInt: 10)

        #expect(small < large)
        #expect(large > small)
        #expect(small <= small)
        #expect(small >= small)
    }

    @Test("Hashable (free from Tagged)")
    func hashable() {
        let a = ExperimentalCount<Int>(experimentUInt: 42)
        let b = ExperimentalCount<Int>(experimentUInt: 42)

        #expect(a.hashValue == b.hashValue)

        var set = Set<ExperimentalCount<Int>>()
        set.insert(a)
        #expect(set.contains(b))
    }

    @Test("Arithmetic")
    func arithmetic() {
        let a = ExperimentalCount<Int>(experimentUInt: 5)
        let b = ExperimentalCount<Int>(experimentUInt: 10)

        let sum = ExperimentalCount<Int>.experimentAdd(a, b)
        #expect(sum.rawValue.rawValue == 15)
    }

    @Test("retag() - THE KEY BENEFIT")
    func retag() {
        let intCount = ExperimentalCount<Int>(experimentUInt: 42)

        // This is what we gain: retag just works!
        let stringCount: ExperimentalCount<String> = intCount.retag(String.self)

        #expect(stringCount.rawValue.rawValue == 42)
    }

    @Test("map() - transform raw value")
    func map() {
        let count = ExperimentalCount<Int>(experimentUInt: 5)

        // Transform the underlying Cardinal.Count
        let doubled = count.map { Cardinal.Count($0.rawValue * 2) }

        #expect(doubled.rawValue.rawValue == 10)
    }

    @Test("Cross-domain conversion via retag")
    func crossDomainConversion() {
        let sourceCount = ExperimentalCount<Int>(experimentUInt: 100)

        // Old pattern required manual init:
        // let destCount = Index<String>.Count(sourceCount)  // manual init

        // New pattern uses retag directly:
        let destCount: ExperimentalCount<String> = sourceCount.retag()

        #expect(destCount.rawValue.rawValue == 100)
    }

    @Test("Phantom type safety preserved")
    func phantomTypeSafety() {
        let intCount = ExperimentalCount<Int>(experimentUInt: 5)
        let stringCount = ExperimentalCount<String>(experimentUInt: 5)

        // These are different types - cannot be compared directly
        // intCount == stringCount  // Would not compile ✓

        // Must explicitly retag to compare
        let retagged: ExperimentalCount<String> = intCount.retag()
        #expect(retagged == stringCount)
    }
}
