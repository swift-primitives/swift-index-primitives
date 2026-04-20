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
typealias ExperimentalCount<Tag: ~Copyable> = Tagged<Tag, Cardinal>

// MARK: - API Compatibility Extensions
// Note: No @inlinable in test code - those would be added in the real implementation

extension Tagged where RawValue == Cardinal, Tag: ~Copyable {

    /// Creates a typed count from an unsigned integer (prototype).
    init(experimentUInt rawValue: UInt) {
        self.init(__unchecked: (), Cardinal(rawValue))
    }

    /// Creates a typed count from a signed integer (prototype).
    init(experimentInt rawValue: Int) throws(Cardinal.Error) {
        self.init(__unchecked: (), try Cardinal(rawValue))
    }

    /// The zero count (prototype).
    static var experimentZero: Self {
        Self(__unchecked: (), Cardinal.zero)
    }

    /// The count of one (prototype).
    static var experimentOne: Self {
        Self(__unchecked: (), Cardinal.one)
    }

    /// Prototype addition.
    static func experimentAdd(_ lhs: Self, _ rhs: Self) -> Self {
        Self(__unchecked: (), lhs.rawValue + rhs.rawValue)
    }
}

// MARK: - Validation Tests

@Suite("Index.Count Tagged Experiment")
struct IndexCountTaggedExperiment {

    @Test
    func `Construction from UInt`() {
        let count = ExperimentalCount<Int>(experimentUInt: 42)
        #expect(count.rawValue == 42)
    }

    @Test
    func `Construction from Int`() throws {
        let count = try ExperimentalCount<Int>(experimentInt: 42)
        #expect(count.rawValue == 42)
    }

    @Test
    func `Construction from negative Int throws`() {
        #expect(throws: Cardinal.Error.self) {
            _ = try ExperimentalCount<Int>(experimentInt: -1)
        }
    }

    @Test
    func `Static constants`() {
        #expect(ExperimentalCount<Int>.experimentZero.rawValue == 0)
        #expect(ExperimentalCount<Int>.experimentOne.rawValue == 1)
    }

    @Test
    func `Equality (free from Tagged)`() {
        let a = ExperimentalCount<Int>(experimentUInt: 5)
        let b = ExperimentalCount<Int>(experimentUInt: 5)
        let c = ExperimentalCount<Int>(experimentUInt: 10)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Comparison (free from Tagged)`() {
        let small = ExperimentalCount<Int>(experimentUInt: 5)
        let large = ExperimentalCount<Int>(experimentUInt: 10)

        #expect(small < large)
        #expect(large > small)
        #expect(small <= small)
        #expect(small >= small)
    }

    @Test
    func `Hashable (free from Tagged)`() {
        let a = ExperimentalCount<Int>(experimentUInt: 42)
        let b = ExperimentalCount<Int>(experimentUInt: 42)

        #expect(a.hashValue == b.hashValue)

        var set = Set<ExperimentalCount<Int>>()
        set.insert(a)
        #expect(set.contains(b))
    }

    @Test
    func `Arithmetic`() {
        let a = ExperimentalCount<Int>(experimentUInt: 5)
        let b = ExperimentalCount<Int>(experimentUInt: 10)

        let sum = ExperimentalCount<Int>.experimentAdd(a, b)
        #expect(sum.rawValue == 15)
    }

    @Test
    func `retag() - THE KEY BENEFIT`() {
        let intCount = ExperimentalCount<Int>(experimentUInt: 42)

        // This is what we gain: retag just works!
        let stringCount: ExperimentalCount<String> = intCount.retag(String.self)

        #expect(stringCount.rawValue == 42)
    }

    @Test
    func `map() - transform raw value`() {
        let count = ExperimentalCount<Int>(experimentUInt: 5)

        // Transform the underlying Cardinal
        let doubled = count.map { Cardinal($0.rawValue * 2) }

        #expect(doubled.rawValue == 10)
    }

    @Test
    func `Cross-domain conversion via retag`() {
        let sourceCount = ExperimentalCount<Int>(experimentUInt: 100)

        // Old pattern required manual init:
        // let destCount = Index<String>.Count(sourceCount)  // manual init

        // New pattern uses retag directly:
        let destCount: ExperimentalCount<String> = sourceCount.retag()

        #expect(destCount.rawValue == 100)
    }

    @Test
    func `Phantom type safety preserved`() {
        let intCount = ExperimentalCount<Int>(experimentUInt: 5)
        let stringCount = ExperimentalCount<String>(experimentUInt: 5)

        // These are different types - cannot be compared directly
        // intCount == stringCount  // Would not compile ✓

        // Must explicitly retag to compare
        let retagged: ExperimentalCount<String> = intCount.retag()
        #expect(retagged == stringCount)
    }
}
