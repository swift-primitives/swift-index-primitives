# ``Index_Primitives_Core/Index``

@Metadata {
    @DisplayName("Index")
    @TitleHeading("Index Primitives")
}

A phantom-typed position into a collection of `Element`.

## Overview

`Index<Element>` is a typealias to `Tagged<Element, Ordinal>` from `swift-tagged-primitives`. The phantom-tag parameter (`Element`) distinguishes one indexing domain from another at compile time — `Index<Bit>` and `Index<Byte>` are different types even though their runtime representation is the same `Ordinal` (which is itself the same as `UInt`).

```swift
private enum Bit {}
private enum Byte {}

let bitIndex:  Index<Bit>  = Index(_unchecked: Ordinal(UInt(5)))
let byteIndex: Index<Byte> = Index(_unchecked: Ordinal(UInt(5)))

// bitIndex == byteIndex     // ❌ compile error — different phantom tags
bitIndex.position            // 5 — the underlying Ordinal
```

## Tagged composition

`Index<Element>` IS `Tagged<Element, Ordinal>` at every layer. Every extension `swift-tagged-primitives` ships on `Tagged<Tag, Ordinal>` is automatically visible on `Index<Element>`, so the typed-indexing surface composes from one source of truth without per-typealias bridging code.

The two forms are interchangeable at type-check time: consumers may write `Tagged<Element, Ordinal>` where `Index<Element>` is expected.

## Construction

```swift
public typealias Index<Element: ~Copyable & ~Escapable> = Tagged<Element, Ordinal>

let idx: Index<Bit> = Index(_unchecked: Ordinal(UInt(5)))
```

The institute convention names safety-bypassing initializers with a leading underscore. `_unchecked:` is a deliberate, audited bypass — the call site is asserting it has already validated the underlying position by other means. The verbose spelling is honest about the safety contract; the verbosity is the point.

For checked construction from a signed `Int`, route through the upstream `Cardinal(_:) throws(Cardinal.Error)` initializer first.

## Arithmetic

`Index<Element>` participates in affine arithmetic against `Index<Element>.Offset` (a signed displacement) and produces `Index<Element>.Offset` when subtracting two indices of the same tag:

```swift
let idx: Index<Bit> = Index(_unchecked: Ordinal(UInt(5)))
let off:  Index<Bit>.Offset = 3
let next: Index<Bit> = try idx + off            // Position 8
let diff: Index<Bit>.Offset = next - idx        // 3
```

Mixing tags is a compile-time error: `Index<Bit>` and `Index<Byte>.Offset` are unrelated types.

## Throwing successor / predecessor

The bounds check is encoded in the type system via the throwing surface — `successor()` and `predecessor()` throw `Ordinal.Error` when the underlying position cannot advance / retreat. There is no infallible variant.

```swift
let zero: Index<Bit> = Index(_unchecked: Ordinal.zero)
let next = try zero.successor()           // OK — position 1
_ = try zero.predecessor()                // throws Ordinal.Error.underflow
```

For call sites that can statically prove bounds, the convention is `try!` with a `// reason: …` comment naming the guard at the call site rather than introducing an infallible API that silently traps. The throwing surface forces the consumer to acknowledge the partiality.

## Conformances

`Index<Element>` inherits every protocol conformance defined on `Tagged<Element, Ordinal>` — `Equatable`, `Comparable`, `Hashable`, `Sendable` (when the underlying parameters conform). No conformance is owned by this package; the typealias is purely a type-system disambiguation device.

See <doc:Phantom-Type-Tags> for the cost model of the `Element: ~Copyable & ~Escapable` constraint, <doc:Tag-Convention> for the declaration patterns for tag types, and <doc:Architecture> for the package's product layout and dependency closure.
