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
import Index_Primitives_Test_Support

private enum Bit {}
private enum Byte {}

// MARK: - Index Test Suites

@Suite("Index")
struct IndexTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension IndexTests.Unit {
    @Test("init with valid position")
    func initWithValidPosition() throws {
        let index: Index<Int> = try Index(5)
        #expect(index.position == 5)
    }

    @Test("init with zero position")
    func initWithZeroPosition() throws {
        let index: Index<String> = try Index(0)
        #expect(index.position == 0)
    }

    @Test("unchecked init bypasses validation")
    func uncheckedInit() {
        let index: Index<Int> = Index(__unchecked: (), Ordinal(42))
        #expect(index.position == 42)
    }

    @Test("position property returns rawValue")
    func positionProperty() throws {
        let index: Index<Int> = try Index(10)
        #expect(index.position == index.rawValue)
    }

    @Test("indices of same type are equatable")
    func equatable() throws {
        let a: Index<Int> = try Index(5)
        let b: Index<Int> = try Index(5)
        let c: Index<Int> = try Index(6)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("indices are comparable")
    func comparable() throws {
        let a: Index<Int> = try Index(3)
        let b: Index<Int> = try Index(7)
        #expect(a < b)
        #expect(b > a)
        #expect(a <= a)
        #expect(b >= b)
    }

    @Test("indices are hashable")
    func hashable() throws {
        let a: Index<Int> = try Index(5)
        let b: Index<Int> = try Index(5)
        #expect(a.hashValue == b.hashValue)

        var set: Set<Index<Int>> = []
        set.insert(a)
        #expect(set.contains(b))
    }

    @Test("description includes type and position")
    func description() throws {
        let index: Index<Int> = try Index(42)
        #expect(index.description.contains("42"))
    }

    @Test("different tag types are incompatible at compile time")
    func typeSafety() throws {
        let bitIndex: Index<Bit> = try Index(5)
        let byteIndex: Index<Byte> = try Index(5)

        // Same position, different types - equality would be compile error
        #expect(bitIndex.position == byteIndex.position)
        // bitIndex == byteIndex // Would not compile - different types
    }
}

// MARK: - Edge Case Tests

extension IndexTests.EdgeCase {
    @Test("init with negative position throws error")
    func negativePositionThrows() {
        #expect(throws: Ordinal.Error.negativeSource(-1)) {
            let _: Index<Int> = try Index(-1)
        }
    }

    @Test("init with large negative position throws error")
    func largeNegativePositionThrows() {
        #expect(throws: Ordinal.Error.negativeSource(Int.min)) {
            let _: Index<Int> = try Index(Int.min)
        }
    }

    @Test("init with maximum Int position succeeds")
    func maxIntPosition() throws {
        let index: Index<Int> = try Index(Int.max)
        let expected: Index<Int> = try Index(Int.max)
        #expect(index == expected)
    }

    @Test("Ordinal.Error is equatable")
    func errorEquatable() {
        let a = Ordinal.Error.negativeSource(-5)
        let b = Ordinal.Error.negativeSource(-5)
        let c = Ordinal.Error.negativeSource(-10)
        #expect(a == b)
        #expect(a != c)
    }
}
