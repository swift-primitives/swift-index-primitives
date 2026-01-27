// ===----------------------------------------------------------------------===//
//
// PROTOTYPE: Index.Count as Tagged Typealias
//
// This file demonstrates Option 3 from index-count-offset-as-tagged.md
// DO NOT USE IN PRODUCTION - for validation only
//
// ===----------------------------------------------------------------------===//

import Cardinal_Primitives
@_spi(Internal) import Identity_Primitives

// MARK: - Type Definition (replaces nested struct)

/*
 PROPOSED CHANGE:

 Instead of:
 ```swift
 extension Tagged where RawValue == Ordinal.Position, Tag: ~Copyable {
     public struct Count: Hashable, Comparable, Sendable {
         public let count: Cardinal.Count
         // ... 100+ lines of manual implementations
     }
 }
 ```

 We define:
 ```swift
 extension Tagged where RawValue == Ordinal.Position, Tag: ~Copyable {
     public typealias Count = Tagged<Tag, Cardinal.Count>
 }
 ```

 Then Index<Foo>.Count = Tagged<Foo, Cardinal.Count>

 All Tagged machinery (retag, map, Equatable, Hashable, Comparable, Sendable) applies automatically.
*/

// MARK: - Simulated typealias (can't actually redefine in same module)

// For prototype purposes, we'll define a parallel type to test the approach
typealias ProtoCount<Tag: ~Copyable> = Tagged<Tag, Cardinal.Count>

// MARK: - API Compatibility Extensions

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {

    // MARK: Compatibility Properties

    /// The underlying cardinal count (API compatibility with nested struct).
    @inlinable
    var count: Cardinal.Count { rawValue }

    // Note: Can't shadow rawValue, but could provide:
    // @inlinable
    // var unsignedValue: UInt { rawValue.rawValue }

    // MARK: Construction

    /// Creates a typed count from an unsigned integer.
    @inlinable
    init(_ rawValue: UInt) {
        self.init(__unchecked: (), Cardinal.Count(rawValue))
    }

    /// Creates a typed count from a signed integer.
    /// - Throws: `Cardinal.Count.Error.negativeSource` if negative.
    @inlinable
    init(_ rawValue: Int) throws(Cardinal.Count.Error) {
        self.init(__unchecked: (), try Cardinal.Count(rawValue))
    }

    /// Creates a typed count without validation.
    @inlinable
    init(__unchecked: Void, _ rawValue: Int) {
        self.init(__unchecked: (), Cardinal.Count(UInt(rawValue)))
    }

    // MARK: Constants

    /// The zero count.
    @inlinable
    static var zero: Self {
        Self(__unchecked: (), Cardinal.Count.zero)
    }

    /// The count of one.
    @inlinable
    static var one: Self {
        Self(__unchecked: (), Cardinal.Count.one)
    }
}

// MARK: - Arithmetic (still needed, but simpler)

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {
    /// Adds two counts (trapping on overflow).
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(__unchecked: (), lhs.rawValue + rhs.rawValue)
    }

    /// Increments the count by another count.
    @inlinable
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}

// MARK: - Cross-Domain Conversion (NOW USES RETAG!)

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {
    /// Creates a count by retagging from a different tag domain.
    ///
    /// **New pattern**: Uses Tagged.retag() instead of manual init.
    ///
    /// ```swift
    /// let rangeCount: Index<Range>.Count = ...
    /// let elementCount = rangeCount.retag(Element.self)  // or:
    /// let elementCount = Index<Element>.Count(rangeCount)  // backward compat
    /// ```
    @inlinable
    init<Other: ~Copyable>(_ other: Tagged<Other, Cardinal.Count>) {
        // Implementation using retag semantics
        self = other.retag(Tag.self)
    }
}

// MARK: - What We Get For Free

/*
 FROM TAGGED CONDITIONAL CONFORMANCES:

 - Equatable (when RawValue: Equatable) ✓ Cardinal.Count is Equatable
 - Hashable (when RawValue: Hashable) ✓ Cardinal.Count is Hashable
 - Comparable (when RawValue: Comparable) ✓ Cardinal.Count is Comparable
 - Sendable (when RawValue: Sendable) ✓ Cardinal.Count is Sendable

 NO MANUAL OPERATORS NEEDED FOR:
 - ==
 - <, <=, >, >=
 - hash(into:)

 FROM TAGGED FUNCTOR:

 - retag<NewTag>() -> Tagged<NewTag, RawValue>
 - map<NewRaw>((RawValue) -> NewRaw) -> Tagged<Tag, NewRaw>
*/

// MARK: - Validation Tests

#if DEBUG
func validatePrototype() {
    // Test 1: Construction
    let count1 = ProtoCount<Int>(5 as UInt)
    let count2 = ProtoCount<Int>(10 as UInt)

    // Test 2: Equality (free from Tagged)
    assert(count1 == count1)
    assert(count1 != count2)

    // Test 3: Comparison (free from Tagged)
    assert(count1 < count2)

    // Test 4: Arithmetic
    let sum = count1 + count2
    assert(sum.rawValue.rawValue == 15)

    // Test 5: Retag (THIS IS THE KEY BENEFIT)
    let retagged: ProtoCount<String> = count1.retag(String.self)
    assert(retagged.rawValue == count1.rawValue)

    // Test 6: Cross-domain init (uses retag internally)
    let converted = ProtoCount<String>(count1)
    assert(converted.rawValue == count1.rawValue)

    // Test 7: Static constants
    assert(ProtoCount<Int>.zero.rawValue.rawValue == 0)
    assert(ProtoCount<Int>.one.rawValue.rawValue == 1)

    // Test 8: Map (transform raw value)
    let doubled = count1.map { Cardinal.Count($0.rawValue * 2) }
    assert(doubled.rawValue.rawValue == 10)

    print("✓ All prototype validations passed")
}
#endif
