// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import Index_Primitives

// MARK: - Test-only Tagged Cardinal alias
//
// Exercises the Tagged<Tag, Cardinal> surface that Index.Count is built on.
// See Research/index-count-offset-as-tagged.md (DECISION).

typealias ExperimentalCount<Tag: ~Copyable> = Tagged<Tag, Cardinal>

// MARK: - API Compatibility Extensions

extension Tagged where Underlying == Cardinal, Tag: ~Copyable {

    /// Creates a typed count from an unsigned integer (prototype).
    init(experimentUInt rawValue: UInt) {
        self.init(_unchecked: Cardinal(rawValue))
    }

    /// Creates a typed count from a signed integer (prototype).
    init(experimentInt rawValue: Int) throws(Cardinal.Error) {
        self.init(_unchecked: try Cardinal(rawValue))
    }

    /// The zero count (prototype).
    static var experimentZero: Self {
        Self(_unchecked: Cardinal.zero)
    }

    /// The count of one (prototype).
    static var experimentOne: Self {
        Self(_unchecked: Cardinal.one)
    }

    /// Prototype addition.
    static func experimentAdd(_ lhs: Self, _ rhs: Self) -> Self {
        Self(_unchecked: lhs.underlying + rhs.underlying)
    }
}

// MARK: - Tagged Cardinal (Index.Count) Tests

@Suite("Index.Count")
struct IndexCountTests {

    @Test
    func `Construction from UInt`() {
        let count = ExperimentalCount<Int>(experimentUInt: 42)
        #expect(count.underlying == 42)
    }

    @Test
    func `Construction from Int`() throws(Cardinal.Error) {
        let count = try ExperimentalCount<Int>(experimentInt: 42)
        #expect(count.underlying == 42)
    }

    @Test
    func `Construction from negative Int throws`() {
        #expect(throws: Cardinal.Error.self) {
            _ = try ExperimentalCount<Int>(experimentInt: -1)
        }
    }

    @Test
    func `Static constants`() {
        #expect(ExperimentalCount<Int>.experimentZero.underlying == 0)
        #expect(ExperimentalCount<Int>.experimentOne.underlying == 1)
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
        #expect(sum.underlying == 15)
    }

    @Test
    func `retag() - THE KEY BENEFIT`() {
        let intCount = ExperimentalCount<Int>(experimentUInt: 42)

        // This is what we gain: retag just works!
        let stringCount: ExperimentalCount<String> = intCount.retag(String.self)

        #expect(stringCount.underlying == 42)
    }

    @Test
    func `map() - transform raw value`() {
        let count = ExperimentalCount<Int>(experimentUInt: 5)

        // Transform the underlying Cardinal
        let doubled = count.map { Cardinal($0.rawValue * 2) }

        #expect(doubled.underlying == 10)
    }

    @Test
    func `Cross-domain conversion via retag`() {
        let sourceCount = ExperimentalCount<Int>(experimentUInt: 100)

        // Old pattern required manual init:
        // let destCount = Index<String>.Count(sourceCount)  // manual init

        // New pattern uses retag directly:
        let destCount: ExperimentalCount<String> = sourceCount.retag()

        #expect(destCount.underlying == 100)
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
