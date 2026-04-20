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
    @Test
    func `init with positive value`() {
        let offset: Index<IntTag>.Offset = 5
        #expect(offset == 5)
    }

    @Test
    func `init with negative value`() {
        let offset: Index<IntTag>.Offset = -3
        #expect(offset == -3)
    }

    @Test
    func `init with zero`() {
        let offset: Index<IntTag>.Offset = 0
        #expect(offset == 0)
    }

    @Test
    func `ExpressibleByIntegerLiteral`() {
        let offset: Index<IntTag>.Offset = 42
        #expect(offset == 42)

        let negative: Index<IntTag>.Offset = -10
        #expect(negative == -10)
    }

    @Test
    func `offsets are equatable`() {
        let a: Index<IntTag>.Offset = 5
        let b: Index<IntTag>.Offset = 5
        let c: Index<IntTag>.Offset = -5
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `offsets are comparable`() {
        let negative: Index<IntTag>.Offset = -10
        let zero: Index<IntTag>.Offset = 0
        let positive: Index<IntTag>.Offset = 10

        #expect(negative < zero)
        #expect(zero < positive)
        #expect(negative < positive)
        #expect(positive > zero)
    }

    @Test
    func `offsets are hashable`() {
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
    @Test
    func `maximum Int offset`() {
        let offset = Index<IntTag>.Offset(Int.max)
        #expect(offset.vector.rawValue == Int.max)
    }

    @Test
    func `minimum Int offset`() {
        let offset = Index<IntTag>.Offset(Int.min)
        #expect(offset.vector.rawValue == Int.min)
    }
}
