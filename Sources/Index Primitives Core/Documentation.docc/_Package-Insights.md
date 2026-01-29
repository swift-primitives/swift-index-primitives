# Index Primitives Insights

<!--
---
title: Index Primitives Insights
version: 1.0.0
last_updated: 2026-01-28
applies_to: [swift-index-primitives]
normative: false
---
-->

@Metadata {
    @TitleHeading("Index Primitives")
}

Design decisions, implementation patterns, and lessons learned specific to this package.

## Overview

This document captures insights that emerged during development of swift-index-primitives. These are not API requirements—they are recorded decisions and patterns that inform future work on this package.

**Document type**: Non-normative (recorded decisions, not requirements).

**Consolidation source**: Reflection entries tagged with `[Package: swift-index-primitives]`.

---

## Positions Cannot Be Scaled—Only Vectors Can

**Date**: 2026-01-27

**Context**: Refactoring Memory.Address strided arithmetic to be affine-correct.

The initial refactoring plan proposed `Position.scaled(by:)` to compute byte offsets from element indices. This violates fundamental affine geometry: in affine space, positions (points) cannot be scaled. Only vectors (displacements) can be scaled. The operation `index × stride` doesn't mean "scale position N by stride"—it means "the displacement from origin to position N, scaled by stride."

The mathematically correct decomposition is:
```
byte_offset = (position - origin) × stride
            = offset_from_origin × stride
```

The fix: add `Index<Tag>.Offset.init(_ index:)` that performs the affine decomposition. This init interprets a position as "displacement from origin" and creates the corresponding offset. The implementation is simple: `self = try index - .zero`. The existing `Index - Index → Offset` operator does the work.

This init throws because the underlying operation can fail—if position > Int.max, the displacement cannot be represented as a signed vector. This partiality is mathematically honest.

The refactoring eliminated `Memory.Address.advanced(by:stride:)` entirely. Instead of wrapping the arithmetic in a method, callers compose operators directly: `address + try Index<Domain>.Offset(index) * stride`. Each operator is defined in the appropriate primitive package. No method hides the mathematics.

**Applies to**: `Index<Tag>.Offset.init(_ index:)`, strided address arithmetic, affine decomposition patterns.

---

## The Offset Infrastructure Was Already There

**Date**: 2026-01-27

**Context**: Discovering existing `Offset * Ratio` operators during refactoring.

The initial plan proposed creating new primitives—scaling operations, new types, wrapper methods. Investigation revealed that everything needed already existed:

- `Index - Index → Offset` in `Index+Arithmetic.swift`
- `Offset * Ratio → Offset` in `Index.Offset+Ratio.swift`
- `Address + Offset → Address` in `Memory.Address.swift`
- `Index<Tag>.zero` constant

The only missing piece was `Offset.init(_ index:)` for the affine decomposition—a three-line init that delegates to existing operators.

Before creating new primitives, thoroughly search existing infrastructure. The primitives ecosystem is designed for composition. The building blocks are often already there; the task is finding how they connect, not creating new ones.

**Applies to**: Infrastructure design decisions, new primitive evaluation, composition patterns.

---

## The @_disfavoredOverload Discovery for Total Arithmetic

**Date**: 2026-01-27

**Context**: Making storage-primitives total by eliminating `try!` force-unwraps in successor/predecessor functions.

Storage-primitives had four `try!` force-unwraps in Ring and Contiguous successor/predecessor methods. The operation `index + .one` was throwing, but the result was always valid (assuming non-negative indices). Why was total arithmetic being treated as partial?

The investigation revealed: `.one` resolved to `Offset.one` (throws) instead of `Count.one` (total). This happened because `@_disfavoredOverload` was placed on the wrong overload in index-primitives:

```swift
// WRONG placement (how it was)
@_disfavoredOverload  // ← On total operation
public func + (lhs: Index, rhs: Count) -> Index  // Total

public func + (lhs: Index, rhs: Offset) throws -> Index  // Throws, but preferred!
```

Swift's overload resolution chose the throwing version by default. Every `index + .one` in the codebase was using the partial operation even when the total operation was mathematically appropriate.

Moving `@_disfavoredOverload` to the throwing overload had immediate benefits. The expression `index + .one` now uses `Count.one` by default—a total operation.

Swift's `@_disfavoredOverload` is a blunt tool—it affects all call sites globally. When designing overloaded operators with different failure characteristics, favor the total operation by default. Users who need the throwing operation can be explicit.

**Applies to**: `Index + Count` vs `Index + Offset` overloads, `@_disfavoredOverload` placement, totality by default design.

---

## Operators Belong at the Mathematical Level

**Date**: 2026-01-28

**Context**: Refactoring Index Primitives to push all arithmetic to Cardinal, Ordinal, and Affine Primitives.

The question "where should this operator be defined?" has a clear answer: at the lowest level where the mathematical operation makes sense. `Tagged<Tag, Cardinal> + Tagged<Tag, Cardinal>` is cardinal arithmetic—it belongs in Cardinal Primitives, not Index Primitives.

This creates a layered architecture:
- **Cardinal Primitives**: `Tagged<Tag, Cardinal>` arithmetic
- **Ordinal Primitives**: `Tagged<Tag, Ordinal> + Tagged<Tag, Cardinal>` (position + count)
- **Affine Primitives**: `Tagged<Tag, Ordinal> ± Tagged<Tag, Vector>` (point ± vector)
- **Index Primitives**: Type aliases only, no operators

After the refactor, Index Primitives Core contains zero arithmetic operators. It defines:
- `Index<E>` as `Tagged<E, Ordinal>`
- `Index<E>.Count` as `Tagged<E, Cardinal>`
- `Index<E>.Offset` as `Tagged<E, Affine.Discrete.Vector>`
- Conversion initializers
- Property-based subtraction (`.subtract.saturating/.exact`)

All arithmetic flows through from lower-level packages via Tagged extensions. This separation isn't about file organization—it's about where mathematical concepts live in the system. Arithmetic is mathematics; Index is structure.

**Applies to**: Package architecture, operator placement, dependency layering.

---

## Constraint Propagation Through Ratio Operator Design

**Date**: 2026-01-27

**Context**: Understanding why `Offset<A> * Ratio<A, B>` produces `Offset<B>`, not `Offset<A>`.

When you multiply `Index<Memory>.Offset(2)` by `Ratio<UInt8, Bit>(8)`, the result is `Index<Bit>.Offset(16)`. The ratio doesn't just scale—it transforms the domain. The output offset lives in the `To` domain, not the `From` domain.

This is mathematically correct. The ratio is a morphism from the UInt8-offset space to the Bit-offset space. Applying it to a UInt8-offset yields a Bit-offset. The type system encodes this category-theoretic structure.

The domain transformation enables type inference through operator chains:

```swift
let byteOffset: Index<Memory>.Offset = ...
let bitOffset = byteOffset * .bitsPerByte  // Type inferred as Index<Bit>.Offset
```

Swift infers that `.bitsPerByte` must be `Ratio<UInt8, Bit>` because the left operand is `Index<Memory>.Offset` and the operator signature requires matching `From` domains. If you accidentally use the wrong ratio, compilation fails—affine geometry enforced by types.

**Applies to**: `Offset * Ratio` operators, domain transformation, type inference through operators.

---

## Constraint Propagation Through Ratio Operator Design

**Date**: 2026-01-27

**Context**: Understanding why `Offset<A> * Ratio<A, B>` produces `Offset<B>`, not `Offset<A>`.

When you multiply `Index<Memory>.Offset(2)` by `Ratio<UInt8, Bit>(8)`, the result is `Index<Bit>.Offset(16)`. The ratio doesn't just scale—it transforms the domain. The output offset lives in the `To` domain, not the `From` domain.

This is mathematically correct. The ratio is a morphism from the UInt8-offset space to the Bit-offset space. Applying it to a UInt8-offset yields a Bit-offset. The type system encodes this category-theoretic structure.

The domain transformation enables type inference through operator chains:

```swift
let byteOffset: Index<Memory>.Offset = ...
let bitOffset = byteOffset * .bitsPerByte  // Type inferred as Index<Bit>.Offset
```

Swift infers that `.bitsPerByte` must be `Ratio<UInt8, Bit>` because the left operand is `Index<Memory>.Offset` and the operator signature requires matching `From` domains. If you accidentally use the wrong ratio, compilation fails—affine geometry enforced by types.

**Applies to**: `Offset * Ratio` operators, domain transformation semantics, type-safe scaling.

---

## Zero Arithmetic as an Architectural Achievement

**Date**: 2026-01-28

**Context**: Completing the refactor with Index Primitives Core containing no arithmetic operators.

Before the refactoring, Index Primitives Core contained:
- `Index+Arithmetic.swift` (226 lines)
- `Index.Count+Arithmetic.swift` (174 lines)
- `Index.Count+Ratio.swift` (64 lines)
- `Index.Offset+Ratio.swift` (62 lines)

Over 500 lines of operator definitions, many duplicating logic that existed at lower levels.

After the refactor:
- `Index+Arithmetic.swift` — deleted
- `Index.Count+Ratio.swift` — deleted
- `Index.Offset+Ratio.swift` — deleted
- `Index.Count+Arithmetic.swift` — reduced to 43 lines (conversion initializers only)

The arithmetic operators now live in:
- `Tagged+Cardinal.swift` in Cardinal Primitives
- `Tagged+Ordinal.swift` in Ordinal Primitives
- `Tagged+Affine.swift` in Affine Primitives

"Index Primitives has no arithmetic" is now a true statement. The package provides type structure; lower-level packages provide operations. This separation isn't about file organization—it's about where mathematical concepts live in the system. Arithmetic is mathematics; Index is structure. They belong in different places.

**Applies to**: Package architecture, arithmetic-free design, type structure vs operations separation.

---

## Topics

### Related Documents

- <doc:Index>
- <doc:Index-Count>
- <doc:Index-Offset>
