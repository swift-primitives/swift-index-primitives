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

import Index_Primitives_Test_Support
import Testing

@testable import Index_Primitives

// Test tag type
private enum IntTag {}

// MARK: - Bounded Test Suites

@Suite("Index.Bounded")
struct IndexBoundedTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit Tests

extension IndexBoundedTests.Unit {
    @Test
    func `integer-literal construction`() {
        let bounded: Index<IntTag>.Bounded<16> = 5
        #expect(bounded.position == 5)
    }

    @Test
    func `checked init within bounds`() {
        let bounded = Index<IntTag>.Bounded<8>(3)
        #expect(bounded.position == 3)
    }

    @Test
    func `capacity reports the static bound`() {
        #expect(Index<IntTag>.Bounded<16>.capacity == 16)
        #expect(Index<IntTag>.Bounded<1>.capacity == 1)
    }

    @Test
    func `unchecked init wraps the position`() {
        let bounded = Index<IntTag>.Bounded<4>(_unchecked: 2)
        #expect(bounded.position == 2)
    }
}

// MARK: - Edge Case Tests

extension IndexBoundedTests.EdgeCase {
    @Test
    func `top of range is in bounds`() {
        let bounded: Index<IntTag>.Bounded<4> = 3  // N - 1
        #expect(bounded.position == 3)
    }

    @Test
    func `zero is in bounds`() {
        let bounded: Index<IntTag>.Bounded<1> = 0
        #expect(bounded.position == 0)
    }
}
