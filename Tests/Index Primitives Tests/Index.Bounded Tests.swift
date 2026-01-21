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


// MARK: - Bounded Test Suites

@Suite("Index.Bounded")
struct IndexBoundedTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension IndexBoundedTests.Unit {
    @Test("init with valid position returns index")
    func initValid() throws {
        let index = try Index<Int>.Bounded<5>.init(3)
        #expect(index == 3)
    }

    @Test("init with zero returns index")
    func initZero() throws {
        let index = try Index<Int>.Bounded<10>.init(0)
        #expect(index == 0)
    }

    @Test("init with max valid position returns index")
    func initMaxValid() throws {
        let index = try Index<Int>.Bounded<5>.init(4)  // N-1
        #expect(index == 4)
    }

    @Test("literal init works for valid values")
    func literalInit() {
        let index: Index<Int>.Bounded<5> = 3
        #expect(index == 3)
    }

    @Test("unchecked init bypasses validation")
    func uncheckedInit() {
        let index: Index<Int>.Bounded<5> = Index<Int>.Bounded(__unchecked: (), 3)
        #expect(index == 3)
    }

    @Test("count returns N")
    func count() {
        #expect(Index<Int>.Bounded<5>.count == 5)
        #expect(Index<Int>.Bounded<100>.count == 100)
        #expect(Index<Int>.Bounded<1>.count == 1)
    }

    @Test("bounded indices are equatable")
    func equatable() {
        let a: Index<Int>.Bounded<5> = 3
        let b: Index<Int>.Bounded<5> = 3
        let c: Index<Int>.Bounded<5> = 4
        #expect(a == b)
        #expect(a != c)
    }

    @Test("bounded indices are comparable")
    func comparable() {
        let a: Index<Int>.Bounded<10> = 2
        let b: Index<Int>.Bounded<10> = 7
        #expect(a < b)
        #expect(b > a)
    }

    @Test("bounded indices are hashable")
    func hashable() {
        let a: Index<Int>.Bounded<5> = 3
        let b: Index<Int>.Bounded<5> = 3
        #expect(a.hashValue == b.hashValue)
    }

    @Test("successor returns next index")
    func successor() {
        let index: Index<Int>.Bounded<5> = 2
        let next = index.successor()
        #expect(next == 3)
    }

    @Test("predecessor returns previous index")
    func predecessor() {
        let index: Index<Int>.Bounded<5> = 2
        let prev = index.predecessor()
        #expect(prev == 1)
    }

    @Test("offset by positive delta")
    func offsetPositive() {
        let index: Index<Int>.Bounded<10> = 3
        let result = index.offset(by: 4)
        #expect(result == 7)
    }

    @Test("offset by negative delta")
    func offsetNegative() {
        let index: Index<Int>.Bounded<10> = 5
        let result = index.offset(by: -3)
        #expect(result == 2)
    }

    @Test("clamped stays within bounds")
    func clamped() {
        let index: Index<Int>.Bounded<10> = 5

        let clampedUp = index.clamped(by: 100)
        #expect(clampedUp == 9)  // N-1

        let clampedDown = index.clamped(by: -100)
        #expect(clampedDown == 0)
    }

    @Test("distance between indices")
    func distance() {
        let a: Index<Int>.Bounded<10> = 2
        let b: Index<Int>.Bounded<10> = 7
        #expect(a.distance(to: b) == 5)
        #expect(b.distance(to: a) == -5)
    }

    @Test("unbounded conversion")
    func unbounded() {
        let bounded: Index<Int>.Bounded<10> = 5
        let unbounded: Index<Int> = bounded.unbounded
        #expect(unbounded.position.rawValue == 5)
    }

    @Test("description includes type and bounds")
    func description() {
        let index: Index<Int>.Bounded<5> = 3
        #expect(index.description.contains("5"))
        #expect(index.description.contains("3"))
    }
}

// MARK: - Edge Case Tests

extension IndexBoundedTests.EdgeCase {
    @Test("init with negative position throws error")
    func negativePosition() {
        #expect(throws: Index<Int>.Bounded<5>.Error.outOfBounds(-1)) {
            _ = try Index<Int>.Bounded<5>.init(-1)
        }
    }

    @Test("init at bound N throws error")
    func atBound() {
        #expect(throws: Index<Int>.Bounded<5>.Error.outOfBounds(5)) {
            _ = try Index<Int>.Bounded<5>.init(5)  // N itself
        }
    }

    @Test("init beyond bound throws error")
    func beyondBound() {
        #expect(throws: Index<Int>.Bounded<5>.Error.outOfBounds(100)) {
            _ = try Index<Int>.Bounded<5>.init(100)
        }
    }

    @Test("successor at max returns nil")
    func successorAtMax() {
        let index: Index<Int>.Bounded<5> = 4  // N-1
        let next = index.successor()
        #expect(next == nil)
    }

    @Test("predecessor at zero returns nil")
    func predecessorAtZero() {
        let index: Index<Int>.Bounded<5> = 0
        let prev = index.predecessor()
        #expect(prev == nil)
    }

    @Test("offset beyond upper bound returns nil")
    func offsetBeyondUpper() {
        let index: Index<Int>.Bounded<5> = 3
        let result = index.offset(by: 5)
        #expect(result == nil)
    }

    @Test("offset beyond lower bound returns nil")
    func offsetBeyondLower() {
        let index: Index<Int>.Bounded<5> = 2
        let result = index.offset(by: -5)
        #expect(result == nil)
    }

    @Test("bounded conversion from unbounded")
    func boundedFromUnbounded() throws {
        let unbounded: Index<Int> = try Index(3)
        let bounded: Index<Int>.Bounded<5>? = unbounded.bounded()
        #expect(bounded == 3)

        let outOfBounds: Index<Int> = try Index(10)
        let failed: Index<Int>.Bounded<5>? = outOfBounds.bounded()
        #expect(failed == nil)
    }

    @Test("single element bounded space")
    func singleElement() {
        let index: Index<Int>.Bounded<1> = 0
        #expect(index.successor() == nil)
        #expect(index.predecessor() == nil)
    }
}
