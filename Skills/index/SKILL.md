---
name: index
description: |
  Typed index patterns using Index<T>, Offset, and Count.
  Apply when working with phantom-typed indices for type-safe collection access.

layer: implementation

requires:
  - swift-institute
  - primitives-conversions

applies_to:
  - swift-index-primitives
  - swift-primitives

last_reviewed: 2026-03-26
---

# Index Primitives

Phantom-typed index patterns for type-safe collection access. Index-primitives provides `Index<T>` with compile-time domain separation.

**Core Types**:
- `Index<T>` — phantom-typed position (`Tagged<T, Ordinal>`)
- `Index<T>.Offset` — signed element displacement (`Tagged<T, Affine.Discrete.Vector>`)
- `Index<T>.Count` — unsigned element count (`Tagged<T, Cardinal>`)

---

## Type Definitions

### [IDX-001] Index as Tagged Ordinal

**Statement**: `Index<Element>` is a typealias for `Tagged<Element, Ordinal>`.

```swift
public typealias Index<Element: ~Copyable> = Tagged<Element, Ordinal>
```

**Properties**:
- `.position: Ordinal` — underlying position value
- `.zero: Index<T>` — first position
- Conforms to `Equatable`, `Hashable`, `Comparable`, `Sendable`

---

### [IDX-002] Index.Offset as Tagged Vector

**Statement**: `Index<T>.Offset` wraps `Affine.Discrete.Vector` for signed displacement.

```swift
public typealias Offset = Tagged<Tag, Affine.Discrete.Vector>
```

**Properties**:
- `.vector: Affine.Discrete.Vector` — underlying displacement
- `.zero: Index<T>.Offset` — no displacement
- Supports negation: `-offset`

---

### [IDX-003] Index.Count as Tagged Cardinal

**Statement**: `Index<T>.Count` wraps `Cardinal` for unsigned count.

```swift
public typealias Count = Tagged<Tag, Cardinal>
```

**Properties**:
- `.count: Cardinal` — underlying count value (via `.rawValue`)
- `.zero: Index<T>.Count` — empty count

---

## Production Patterns

### [IDX-004] Type-Safe Domain Separation

**Statement**: Use different phantom types to prevent mixing indices from different domains.

```swift
enum Bit {}
enum Byte {}

let bitIndex: Index<Bit> = try Index(5)
let byteIndex: Index<Byte> = try Index(5)

// Same position, different types
bitIndex.position == byteIndex.position  // true (Ordinal comparison)
// bitIndex == byteIndex  // ❌ Compile error - different Index types
```

**Rationale**: Phantom types catch domain confusion at compile time.

---

### [IDX-005] Construction from Int

**Statement**: Use throwing or optional initializers for Int → Index conversion.

```swift
// Throwing (validates non-negative)
let index: Index<Int> = try Index(5)

// Optional (returns nil if negative)
let maybeIndex: Index<Int>? = Index(exactly: -1)  // nil

// From Ordinal (total)
let index = Index<Int>(ordinal)

// From Cardinal (total)
let index = Index<Int>(cardinal)
```

---

### [IDX-006] Index Arithmetic with Offset

**Statement**: Use `Index + Offset → Index` and `Index - Index → Offset`.

```swift
let start: Index<Int> = try Index(5)
let offset: Index<Int>.Offset = 3

// Advance by offset (may throw on underflow)
let end = try start + offset  // Index at position 8

// Compute displacement
let distance: Index<Int>.Offset = try end - start  // Offset of 3
```

**Arithmetic**:
- `Index + Offset → Index` (throws)
- `Index - Offset → Index` (throws)
- `Offset + Index → Index` (commutative, throws)
- `Index - Index → Offset` (throws)

---

### [IDX-006a] Index Arithmetic with Count (Total)

**Statement**: Use `Index + Count → Index` for forward advancement. This is **total** (non-throwing).

```swift
var position: Index<Int> = .zero
let count: Index<Int>.Count = try Index<Int>.Count(3)

// Advance by count - pure typed arithmetic, total!
position = position + count  // Index at position 3

// Single element increment
position = position + .one   // Index at position 4
```

**Arithmetic**:
- `Index + Count → Index` (total, from ordinal-primitives)
- `Count + Index → Index` (commutative)

**Key insight**: `Index + Count` is total because both are non-negative. Prefer this over `Index + Offset` when the displacement is known to be non-negative.

---

### [IDX-006b] Typed Position as Primary Representation

**Statement**: When wrapping stdlib collections, store `Index<Element>` as the primary position representation. Derive raw `Storage.Index` only at subscript boundaries.

```swift
struct Cursor<Base: RandomAccessCollection> {
    let base: Base
    var position: Index<Base.Element>  // PRIMARY: typed index

    // Derive raw index only for subscripting (O(1) for RandomAccessCollection)
    var rawIndex: Base.Index {
        base.index(base.startIndex, offsetBy: Int(bitPattern: position))
    }

    // Pure typed arithmetic - no scalar conversions!
    mutating func advance(by count: Index<Base.Element>.Count) {
        position = position + count
    }

    var current: Base.Element? {
        guard position < totalCount else { return nil }
        return base[rawIndex]  // Single conversion point
    }
}
```

**Benefits**:
- All arithmetic stays typed: `position + count`
- `Int(bitPattern:)` conversion encapsulated in single `rawIndex` getter
- No dual tracking needed

**Cross-references**: See experiment `swift-primitives/Experiments/typed-index-boundary/`

---

### [IDX-006c] Index ↔ Count Conversions

**Statement**: Convert between `Index<T>` and `Index<T>.Count` using initializers. Both directions are total because both represent non-negative values.

```swift
let position: Index<Int> = try Index(5)

// Index → Count (total)
let consumed: Index<Int>.Count = Index<Int>.Count(position)

// Count → Index (total)
let count: Index<Int>.Count = try Index<Int>.Count(10)
let endIndex: Index<Int> = Index<Int>(count)
```

**Use case**: Computing remaining elements and bounds:
```swift
var totalCount: Index<Element>.Count { try! Index<Element>.Count(storage.count) }
var consumedCount: Index<Element>.Count { Index<Element>.Count(position) }
var checkpointRange: ClosedRange<Index<Element>> { .zero...Index<Element>(totalCount) }
```

---

### [IDX-006d] Count Subtraction (Saturating)

**Statement**: Use `.subtract.saturating()` for `Count - Count` operations. Direct `-` operator is not defined on Count.

```swift
let total: Index<Int>.Count = try Index<Int>.Count(10)
let consumed: Index<Int>.Count = try Index<Int>.Count(3)

// ✓ CORRECT: Property-based saturating subtraction
let remaining = total.subtract.saturating(consumed)  // Count of 7

// ❌ WRONG: No direct - operator on Count
// let remaining = total - consumed  // Does not compile
```

**Rationale**: Subtraction on cardinals (non-negative quantities) could underflow. The property-based API makes the saturation behavior explicit.

**Pattern in practice**:
```swift
public var count: Index<Element>.Count {
    totalCount.subtract.saturating(Index<Element>.Count(position))
}
```

---

### [IDX-007] Bounds Checking

**Statement**: Use `Index < Count` for bounds validation.

```swift
let index: Index<Int> = try Index(5)
let count: Index<Int>.Count = 10

guard index < count else {
    return nil  // Out of bounds
}
```

**Cross-type comparisons** (disfavored overloads):
- `Index < Count`
- `Index <= Count`
- `Index > Count`
- `Index >= Count`

---

### [IDX-008] Range Iteration

**Statement**: Use `(.zero..<count)` for index ranges.

```swift
let count: Index<Int>.Count = 8

(.zero..<count).forEach { index in
    // index: Index<Int>
    process(at: index)
}
```

**Pattern**: Range produces `Index<T>` values via iteration.

---

### [IDX-009] Position Access

**Statement**: Access `.position` to get the underlying `Ordinal`.

```swift
let index: Index<Int> = try Index(5)
let ordinal: Ordinal = index.position

// Ordinal comparisons
#expect(index.position == 5)  // Ordinal literal comparison
```

---

### [IDX-010] Retag for Domain Conversion

**Statement**: Use `.retag()` for zero-cost cross-domain conversion.

```swift
let bitOffset: Index<Bit>.Offset = 5
let byteOffset: Index<Byte>.Offset = bitOffset.retag(Byte.self)
```

**Note**: Retagging changes phantom type only — underlying value unchanged.

---

## Test Support Patterns

### [IDX-011] Import Test Support

**Statement**: Import `Index_Primitives_Test_Support` for test conveniences.

```swift
import Testing
@testable import Index_Primitives
import Index_Primitives_Test_Support  // ← Enables literals
```

**Re-export chain**:
```
Index_Primitives_Test_Support
  @_exported import Identity_Primitives_Test_Support  // Literal conformances
  @_exported import Ordinal_Primitives_Test_Support
  @_exported import Cardinal_Primitives_Test_Support
  @_exported import Affine_Primitives_Test_Support
```

---

### [IDX-012] Literal Index Construction

**Statement**: Use integer literals for index construction in tests.

```swift
// Via Test Support literal conformance
let index: Index<Int> = 5
let offset: Index<Int>.Offset = -3
let count: Index<Int>.Count = 10
```

**Without Test Support** (production):
```swift
let index: Index<Int> = try Index(5)
let offset: Index<Int>.Offset = Index<Int>.Offset(3)
let count: Index<Int>.Count = Index<Int>.Count(Cardinal(10))
```

---

### [IDX-013] Literal Comparison

**Statement**: Use literal syntax for comparisons in tests.

```swift
let index: Index<Int> = 5

// ✓ CORRECT: Literal comparison
#expect(index == 5)
#expect(index.position == 5)

// ❌ WRONG: rawValue unwrapping
#expect(index.position.rawValue == 5)
```

---

### [IDX-014] Literal Offset Comparison

**Statement**: Use literal syntax for offset comparisons.

```swift
let offset: Index<Int>.Offset = 5
#expect(offset == 5)

let negative: Index<Int>.Offset = -3
#expect(negative == -3)
```

---

### [IDX-015] External Counter Pattern

**Statement**: Use external counter for test value computation, not index conversion.

**Correct**:
```swift
var i = 0
(.zero..<count).forEach { index in
    storage[index] = i * 10
    i += 1
}
```

**Incorrect**:
```swift
(.zero..<count).forEach { index in
    // ❌ Never convert index to compute value
    storage[index] = Int(bitPattern: index.position.rawValue) * 10
}
```

---

### [IDX-016] Test Suite Structure

**Statement**: Use type extension pattern for Index test suites.

```swift
private enum IntTag {}

@Suite("Index")
struct IndexTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

extension IndexTests.Unit {
    @Test
    func `init with valid position`() throws {
        let index: Index<Int> = try Index(5)
        #expect(index.position == 5)
    }
}
```

**Note**: Generic type specializations (like `Index<Int>`) require parallel namespace pattern due to Swift Testing limitation.

---

## Standard Library Integration

### [IDX-017] RandomAccessCollection Offset

**Statement**: Use `Index<T>.Offset` with `collection.index(_:offsetBy:)`.

```swift
let array = [10, 20, 30, 40, 50]
let offset: Index<Int>.Offset = 3

let newIndex = array.index(array.startIndex, offsetBy: offset)
#expect(array[newIndex] == 40)
```

---

### [IDX-018] Span with Index.Count

**Statement**: Use `Index<T>.Count` for Span construction.

```swift
let span = Span(
    _unsafeStart: pointer,
    count: Index<Element>.Count(elementCount)
)
```

---

## Cross-References

See also:
- **primitives-conversions** skill for [CONV-001] rawValue location
- **pointer-arithmetic** skill for Pointer<T> subscripts with Index<T>
- **memory-arithmetic** skill for ratio scaling with Index<T>.Offset/Count
- **testing** skill for [TEST-018] literal conformances
- Test file: `Tests/Index Primitives Tests/Index Tests.swift`
