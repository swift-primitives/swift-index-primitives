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
import Hash_Primitives
@testable import Hash_Index_Primitives

// Note: Swift Testing's #expect macro has issues with ~Copyable types in property access.
// Workaround: Extract values to local Copyable variables before using #expect.

@Suite("Hash.Index Tests")
struct HashIndexTests {
    @Test("Empty hash index")
    func emptyHashIndex() {
        let index = Hash.Index()
        let isEmpty = index.isEmpty
        let count = index.count
        #expect(isEmpty == true)
        #expect(count == 0)
    }

    @Test("Insert and lookup")
    func insertAndLookup() {
        var index = Hash.Index()

        // Insert position 0 with hash 42
        let inserted = index.insert(position: 0, hashValue: 42, equals: { _ in false })
        #expect(inserted == true)

        let count = index.count
        #expect(count == 1)

        // Lookup should find it
        let found = index.position(forHash: 42, equals: { $0 == 0 })
        #expect(found == 0)

        // Lookup with wrong hash should not find it
        let notFound = index.position(forHash: 99, equals: { _ in true })
        #expect(notFound == nil)
    }

    @Test("Duplicate rejection")
    func duplicateRejection() {
        var index = Hash.Index()

        let first = index.insert(position: 0, hashValue: 42, equals: { _ in false })
        #expect(first == true)

        // Same hash, equals returns true → duplicate
        let duplicate = index.insert(position: 1, hashValue: 42, equals: { $0 == 0 })
        #expect(duplicate == false)

        let count = index.count
        #expect(count == 1)
    }

    @Test("Removal")
    func removal() {
        var index = Hash.Index()

        index.insert(position: 0, hashValue: 42, equals: { _ in false })
        index.insert(position: 1, hashValue: 99, equals: { _ in false })

        let countBefore = index.count
        #expect(countBefore == 2)

        let removed = index.remove(hashValue: 42, equals: { $0 == 0 })
        #expect(removed == 0)

        let countAfter = index.count
        #expect(countAfter == 1)

        // Should not find removed element
        let notFound = index.position(forHash: 42, equals: { $0 == 0 })
        #expect(notFound == nil)

        // Other element still present
        let stillThere = index.position(forHash: 99, equals: { $0 == 1 })
        #expect(stillThere == 1)
    }

    @Test("Position decrement after removal")
    func positionDecrementAfterRemoval() {
        var index = Hash.Index()

        // Insert positions 0, 1, 2
        index.insertUnchecked(position: 0, hashValue: 10)
        index.insertUnchecked(position: 1, hashValue: 20)
        index.insertUnchecked(position: 2, hashValue: 30)

        // Remove from external storage at position 1
        index.remove(hashValue: 20, equals: { $0 == 1 })
        index.decrementPositions(after: 1)

        // Position 0 unchanged
        let pos0 = index.position(forHash: 10, equals: { $0 == 0 })
        #expect(pos0 == 0)

        // Position 2 now at position 1
        let pos1 = index.position(forHash: 30, equals: { $0 == 1 })
        #expect(pos1 == 1)
    }

    @Test("Growth under load")
    func growthUnderLoad() {
        var index = Hash.Index(minimumCapacity: 4)
        let initialCapacity = index.capacity

        // Insert enough elements to trigger growth
        for i in 0..<20 {
            index.insertUnchecked(position: i, hashValue: i * 7)
        }

        let count = index.count
        let capacity = index.capacity
        #expect(count == 20)
        #expect(capacity > initialCapacity)

        // All elements should still be findable
        for i in 0..<20 {
            let found = index.position(forHash: i * 7, equals: { $0 == i })
            #expect(found == i)
        }
    }

    @Test("Remove all keeping capacity")
    func removeAllKeepingCapacity() {
        var index = Hash.Index()

        for i in 0..<10 {
            index.insertUnchecked(position: i, hashValue: i * 3)
        }

        let capacityBefore = index.capacity
        index.removeAll(keepingCapacity: true)

        let isEmpty = index.isEmpty
        let count = index.count
        let capacityAfter = index.capacity
        #expect(isEmpty == true)
        #expect(count == 0)
        #expect(capacityAfter == capacityBefore)
    }

    @Test("Remove all releasing capacity")
    func removeAllReleasingCapacity() {
        var index = Hash.Index(minimumCapacity: 100)

        for i in 0..<50 {
            index.insertUnchecked(position: i, hashValue: i * 5)
        }

        index.removeAll(keepingCapacity: false)

        let isEmpty = index.isEmpty
        let count = index.count
        #expect(isEmpty == true)
        #expect(count == 0)
    }

    @Test("Hash collision handling")
    func hashCollisionHandling() {
        var index = Hash.Index()

        // Insert multiple elements with the same hash
        index.insert(position: 0, hashValue: 42, equals: { _ in false })
        index.insert(position: 1, hashValue: 42, equals: { _ in false })
        index.insert(position: 2, hashValue: 42, equals: { _ in false })

        let count = index.count
        #expect(count == 3)

        // Each should be findable with correct equals
        let found0 = index.position(forHash: 42, equals: { $0 == 0 })
        let found1 = index.position(forHash: 42, equals: { $0 == 1 })
        let found2 = index.position(forHash: 42, equals: { $0 == 2 })
        #expect(found0 == 0)
        #expect(found1 == 1)
        #expect(found2 == 2)
    }
}
