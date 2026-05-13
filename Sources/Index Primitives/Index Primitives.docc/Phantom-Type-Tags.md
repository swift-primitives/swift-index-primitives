# Phantom Type Tags

@Metadata {
    @TitleHeading("Index Primitives")
}

Why `Element: ~Copyable` in `Index<Element>` is cost-free.

## Overview

The full declaration is:

```swift
public typealias Index<Element: ~Copyable> = Tagged<Element, Ordinal>
```

Two questions follow naturally: does the `~Copyable` constraint propagate into the `Index<Element>` value's own copyability? And: what is the runtime cost of carrying the phantom parameter?

The answers — *no* and *zero* — depend on understanding what "phantom" means here.

## Phantom: the parameter is never stored

`Tagged<Tag, Underlying>` from `swift-tagged-primitives` stores exactly one value: an `Underlying`. The `Tag` parameter exists only at the type level — there is no `Tag`-typed field in the layout. The compiler uses `Tag` to *distinguish* `Tagged<Bit, Ordinal>` from `Tagged<Byte, Ordinal>` at type-check time, then forgets about it by the time the value is laid out in memory.

The runtime layout of `Index<Bit>` is therefore identical to:

- `Tagged<Bit, Ordinal>` (by typealias)
- `Ordinal` (by `Tagged`'s layout rule — one stored `Underlying`)
- `UInt` (by `Ordinal`'s layout rule — one stored `UInt`)

A `Sequence<Index<Bit>>` and a `Sequence<UInt>` use the same memory, the same registers, the same calling convention. The phantom-tag overhead is in the type-checker, not the codegen.

## `Element: ~Copyable` widens, not restricts

When the constraint reads `Element: ~Copyable`, it does not say "`Element` must be noncopyable" — it says "`Element` is *permitted* to be noncopyable." The `~Copyable` form removes the implicit `Copyable` bound that every generic parameter carries by default (per SE-0427).

The practical effect: consumers may use a `~Copyable` tag for `Index<Element>`. For example, a tag that wraps a unique-resource handle:

```swift
struct ResourceTag: ~Copyable { /* … */ }

let idx: Index<ResourceTag> = Index(_unchecked: Ordinal(UInt(5)))
```

`Index<ResourceTag>` is itself **Copyable**, because:

1. `Index<ResourceTag>` is `Tagged<ResourceTag, Ordinal>`.
2. `Tagged<T, U>`'s copyability depends on the copyability of its *stored* fields — and the only stored field is `Ordinal`, which is `Copyable`.
3. `ResourceTag` is never stored. The phantom never participates in copyability.

So the `~Copyable` widening costs nothing at the value level: `Index<ResourceTag>` copies freely. The constraint only buys the consumer the *option* of using a `~Copyable` tag.

For the much more common case of a plain `Copyable` tag — `private enum Bit {}`, `private enum Byte {}` — the `~Copyable` bound is automatically satisfied and never observed. The cost path and the constraint path are the same path.

## Reading the cost: zero

Because the phantom is never stored:

- **Stack cost**: identical to `UInt`.
- **Heap cost**: zero — `Index<Element>` is never heap-allocated unless boxed inside a collection.
- **Copy cost**: identical to `UInt` (`Bitwise Copyable`).
- **Constraint cost**: the `~Copyable` bound is a type-checker bookkeeping line, not a runtime check.

The Tagged primitive's own benchmarks (see `swift-tagged-primitives`) verify this with disassembly; `Index<Element>` inherits the result by typealias.

See <doc:Tag-Convention> for how to declare phantom tag types in consumer code, and <doc:Index> for the typealias itself.
