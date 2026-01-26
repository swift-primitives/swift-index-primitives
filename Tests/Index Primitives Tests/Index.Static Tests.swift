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
@_spi(Internal) import Index_Primitives_Test_Support
import Cyclic_Primitives

// MARK: - Static Test Suites

@Suite("Index.Static")
struct IndexStaticTests {
    @Suite struct Construction {}
    @Suite struct Arithmetic {}
    @Suite struct Conformances {}
    @Suite struct EdgeCase {}
}

// MARK: - Construction Tests

extension IndexStaticTests.Construction {
    @Test("init with valid position returns index")
    func initValid() throws {
        let index = try Index<Int>.Static<5>.init(3)
        #expect(index.rawValue.rawValue == 3)
    }

    @Test("init with zero returns index")
    func initZero() throws {
        let index = try Index<Int>.Static<10>.init(0)
        #expect(index.rawValue.rawValue == 0)
    }

    @Test("init with max valid position returns index")
    func initMaxValid() throws {
        let index = try Index<Int>.Static<5>.init(4)  // N-1
        #expect(index.rawValue.rawValue == 4)
    }

    @Test("unchecked init bypasses validation")
    func uncheckedInit() {
        let index = Index<Int>.Static<5>.init(__unchecked: 3)
        #expect(index.rawValue.rawValue == 3)
    }

    @Test("init with negative position throws error")
    func negativePosition() {
        #expect(throws: StaticError<5>.outOfBounds(-1)) {
            _ = try Index<Int>.Static<5>.init(-1)
        }
    }

    @Test("init at bound N throws error")
    func atBound() {
        #expect(throws: StaticError<5>.outOfBounds(5)) {
            _ = try Index<Int>.Static<5>.init(5)
        }
    }

    @Test("init beyond bound throws error")
    func beyondBound() {
        #expect(throws: StaticError<5>.outOfBounds(100)) {
            _ = try Index<Int>.Static<5>.init(100)
        }
    }
}

// MARK: - Arithmetic Tests

extension IndexStaticTests.Arithmetic {
    @Test("addition of two static indices")
    func additionTaggedTagged() throws {
        let a = try Index<Int>.Static<10>.init(3)
        let b = try Index<Int>.Static<10>.init(4)
        let result = a + b
        #expect(result.rawValue.rawValue == 7)
    }

    @Test("subtraction of two static indices")
    func subtractionTaggedTagged() throws {
        let a = try Index<Int>.Static<10>.init(7)
        let b = try Index<Int>.Static<10>.init(3)
        let result = a - b
        #expect(result.rawValue.rawValue == 4)
    }

    @Test("compound addition assignment")
    func compoundAddition() throws {
        var index = try Index<Int>.Static<10>.init(3)
        let addend = try Index<Int>.Static<10>.init(2)
        index += addend
        #expect(index.rawValue.rawValue == 5)
    }

    @Test("compound subtraction assignment")
    func compoundSubtraction() throws {
        var index = try Index<Int>.Static<10>.init(5)
        let subtrahend = try Index<Int>.Static<10>.init(2)
        index -= subtrahend
        #expect(index.rawValue.rawValue == 3)
    }

    @Test("addition with .one element")
    func additionWithOne() throws {
        let index = try Index<Int>.Static<10>.init(3)
        let result = index + .one
        #expect(result.rawValue.rawValue == 4)
    }

    @Test("subtraction with .one element")
    func subtractionWithOne() throws {
        let index = try Index<Int>.Static<10>.init(3)
        let result = index - .one
        #expect(result.rawValue.rawValue == 2)
    }

    @Test("addition with .zero element")
    func additionWithZero() throws {
        let index = try Index<Int>.Static<10>.init(5)
        let result = index + .zero
        #expect(result.rawValue.rawValue == 5)
    }

    @Test("compound addition with element")
    func compoundAdditionElement() throws {
        var index = try Index<Int>.Static<10>.init(3)
        index += .one
        #expect(index.rawValue.rawValue == 4)
    }

    @Test("compound subtraction with element")
    func compoundSubtractionElement() throws {
        var index = try Index<Int>.Static<10>.init(3)
        index -= .one
        #expect(index.rawValue.rawValue == 2)
    }

    @Test("cyclic addition wraps at bound")
    func cyclicAdditionWrap() throws {
        let index = try Index<Int>.Static<5>.init(4)  // N-1
        let result = index + .one
        #expect(result.rawValue.rawValue == 0)  // Wraps to 0
    }

    @Test("cyclic subtraction wraps at zero")
    func cyclicSubtractionWrap() throws {
        let index = try Index<Int>.Static<5>.init(0)
        let result = index - .one
        #expect(result.rawValue.rawValue == 4)  // Wraps to N-1
    }

    @Test("multiple wrap-arounds")
    func multipleWrapArounds() throws {
        var index = try Index<Int>.Static<3>.init(0)
        index += .one  // 1
        index += .one  // 2
        index += .one  // 0 (wrap)
        index += .one  // 1
        #expect(index.rawValue.rawValue == 1)
    }
}

// MARK: - Conformance Tests

extension IndexStaticTests.Conformances {
    @Test("static indices are equatable")
    func equatable() throws {
        let a = try Index<Int>.Static<5>.init(3)
        let b = try Index<Int>.Static<5>.init(3)
        let c = try Index<Int>.Static<5>.init(4)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("static indices are comparable")
    func comparable() throws {
        let a = try Index<Int>.Static<10>.init(2)
        let b = try Index<Int>.Static<10>.init(7)
        #expect(a < b)
        #expect(b > a)
        #expect(a <= b)
        #expect(b >= a)
    }

    @Test("static indices are hashable")
    func hashable() throws {
        let a = try Index<Int>.Static<5>.init(3)
        let b = try Index<Int>.Static<5>.init(3)
        #expect(a.hashValue == b.hashValue)
    }

    @Test("static indices can be used in sets")
    func setUsage() throws {
        let a = try Index<Int>.Static<5>.init(1)
        let b = try Index<Int>.Static<5>.init(2)
        let c = try Index<Int>.Static<5>.init(1)
        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    @Test("static indices can be used as dictionary keys")
    func dictionaryUsage() throws {
        let key = try Index<Int>.Static<5>.init(3)
        var dict: [Index<Int>.Static<5>: String] = [:]
        dict[key] = "value"
        #expect(dict[key] == "value")
    }
}

// MARK: - Edge Case Tests

extension IndexStaticTests.EdgeCase {
    @Test("single element static space")
    func singleElement() throws {
        let index = try Index<Int>.Static<1>.init(0)
        let incremented = index + .one
        #expect(incremented.rawValue.rawValue == 0)  // Wraps back to 0

        let decremented = index - .one
        #expect(decremented.rawValue.rawValue == 0)  // Wraps back to 0
    }

    @Test("different phantom types are incompatible")
    func phantomTypeSafety() throws {
        enum TagA {}
        enum TagB {}

        let a = try Index<TagA>.Static<5>.init(3)
        let b = try Index<TagB>.Static<5>.init(3)

        // These should have the same raw value but different types
        #expect(a.rawValue.rawValue == b.rawValue.rawValue)
        // Cannot compare a == b due to different types (compile-time safety)
    }

    @Test("rawValue access returns cyclic element")
    func rawValueAccess() throws {
        let index = try Index<Int>.Static<5>.init(3)
        let element: Cyclic.Group<5>.Element = index.rawValue
        #expect(element.rawValue == 3)
    }

    @Test("StaticError is Hashable")
    func errorHashable() {
        let error1 = StaticError<5>.outOfBounds(10)
        let error2 = StaticError<5>.outOfBounds(10)
        let error3 = StaticError<5>.outOfBounds(20)
        #expect(error1 == error2)
        #expect(error1 != error3)
    }

    @Test("StaticError is Sendable")
    func errorSendable() async {
        let error = StaticError<5>.outOfBounds(10)
        await Task {
            #expect(error == StaticError<5>.outOfBounds(10))
        }.value
    }
}
