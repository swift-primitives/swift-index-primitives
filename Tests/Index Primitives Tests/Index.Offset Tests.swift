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

// Test tag type
private enum IntTag {}

// MARK: - Offset Test Suites

@Suite("Index.Offset")
struct IndexOffsetTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension IndexOffsetTests.Unit {
    @Test("init with positive value")
    func initPositive() {
        let offset: Index<IntTag>.Offset = Index<IntTag>.Offset(5)
        #expect(offset.rawValue == 5)
    }

    @Test("init with negative value")
    func initNegative() {
        let offset: Index<IntTag>.Offset = Index<IntTag>.Offset(-3)
        #expect(offset.rawValue == -3)
    }

    @Test("init with zero")
    func initZero() {
        let offset: Index<IntTag>.Offset = Index<IntTag>.Offset(0)
        #expect(offset.rawValue == 0)
    }

    @Test("ExpressibleByIntegerLiteral")
    func integerLiteral() {
        let offset: Index<IntTag>.Offset = 42
        #expect(offset.rawValue == 42)

        let negative: Index<IntTag>.Offset = -10
        #expect(negative.rawValue == -10)
    }

    @Test("offsets are equatable")
    func equatable() {
        let a: Index<IntTag>.Offset = 5
        let b: Index<IntTag>.Offset = 5
        let c: Index<IntTag>.Offset = -5
        #expect(a == b)
        #expect(a != c)
    }

    @Test("offsets are comparable")
    func comparable() {
        let negative: Index<IntTag>.Offset = -10
        let zero: Index<IntTag>.Offset = 0
        let positive: Index<IntTag>.Offset = 10

        #expect(negative < zero)
        #expect(zero < positive)
        #expect(negative < positive)
        #expect(positive > zero)
    }

    @Test("offsets are hashable")
    func hashable() {
        let a: Index<IntTag>.Offset = 5
        let b: Index<IntTag>.Offset = 5
        #expect(a.hashValue == b.hashValue)

        var set: Set<Index<IntTag>.Offset> = []
        set.insert(a)
        #expect(set.contains(b))
    }
}

// MARK: - Edge Case Tests

extension IndexOffsetTests.EdgeCase {
    @Test("maximum Int offset")
    func maxIntOffset() {
        let offset: Index<IntTag>.Offset = Index<IntTag>.Offset(Int.max)
        #expect(offset.rawValue == Int.max)
    }

    @Test("minimum Int offset")
    func minIntOffset() {
        let offset: Index<IntTag>.Offset = Index<IntTag>.Offset(Int.min)
        #expect(offset.rawValue == Int.min)
    }
}
