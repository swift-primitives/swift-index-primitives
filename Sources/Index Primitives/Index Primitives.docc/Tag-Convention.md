# Tag Convention

@Metadata {
    @TitleHeading("Index Primitives")
}

How to declare phantom tag types in consumer code.

## Overview

`Index<Element>` uses the `Element` type parameter purely as a compile-time disambiguation tag. Consumers declare tag types as case-less, payload-less type bodies — there is no value-level content; the tag exists only so the compiler can tell two `Index<…>` types apart.

The convention is **a `private enum` with no cases**:

```swift
private enum Bit {}
private enum Byte {}

let bitIndex:  Index<Bit>  = Index(_unchecked: Ordinal(UInt(5)))
let byteIndex: Index<Byte> = Index(_unchecked: Ordinal(UInt(5)))
```

A case-less enum is the lightest declaration that produces a distinct type identity. It cannot be instantiated (no cases), it has no stored state, and it cannot be subclassed (enums are non-classy). Mixing two indices with different tags is a compile-time error:

```swift
// bitIndex == byteIndex   // ❌ compile error — different phantom tags
```

## When to use `private` vs `public` vs `internal`

The visibility of the tag type determines who can construct `Index<Tag>` values.

| Visibility | When to use |
|------------|-------------|
| `private` | The tag is local to a single file's index-using code (the most common case). |
| `internal` | The tag is shared across a module — consumers in the same module can construct `Index<Tag>` values without exposing the tag publicly. |
| `public` | The tag is part of the module's public API (e.g., re-exposing a typed-index API across module boundaries). |

A `public` tag does not weaken type safety — `Index<Bit>` and `Index<Byte>` remain distinct types regardless of where `Bit` and `Byte` are declared. The visibility choice only controls who can *write* `Index<Bit>` in their code.

## Reusing tags across `Index`, `Offset`, `Count`

A single tag type can serve as the phantom for `Index`, `Offset`, and `Count` simultaneously — that's the design intent. The cohort's typed-indexing surface uses the same tag across the three roles:

```swift
private enum BitBuffer {}

let position: Index<BitBuffer>        = Index(_unchecked: Ordinal.zero)
let count:    Index<BitBuffer>.Count  = .zero
let stride:   Index<BitBuffer>.Offset = 1
```

All three are `Tagged<BitBuffer, …>` with different `Underlying` parameters. They share the tag identity and so compose cleanly: `position + stride` is `Index<BitBuffer>`, distinguishable from `Index<OtherBuffer>` even if the operations look textually identical.

## What NOT to do

Don't use a type that carries runtime state as a phantom tag:

```swift
// ❌ struct with stored fields — uses memory, runs constructors, none of it matters
struct Bit { let _unused: Int = 0 }
```

The compiler may still accept this, but it is wasteful: the type's storage is never observed via the phantom path, yet the type's existence forces unnecessary metadata. Use case-less enums.

Don't use a type from a non-imported module as a phantom tag in a public API surface unless the tag type is also exported. The compiler requires the tag type to be visible at the use site; otherwise `Index<HiddenTag>` becomes unmentionable downstream.

See <doc:Phantom-Type-Tags> for why `Element: ~Copyable` is cost-free at the value layer, and <doc:Index> for the typealias itself.
