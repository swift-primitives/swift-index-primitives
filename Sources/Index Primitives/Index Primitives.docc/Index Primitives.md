# ``Index_Primitives``

@Metadata {
    @DisplayName("Index Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

A phantom-typed index primitive — `Index<Element>`, a type-safe position into a collection of `Element`, built on `Ordinal` and the `Tagged` phantom-type machinery.

## Overview

`Index_Primitives` ships ``Index_Primitives_Core/Index``, a one-line typealias `Tagged<Element, Ordinal>` that distinguishes "an index into bits" from "an index into bytes" *at compile time*. Mixing the two — accidentally subscripting a byte buffer with a bit index — becomes a type error rather than a silent off-by-one bug.

The phantom-tag parameter (`Element`) never appears at runtime, is never stored, and never copies. The runtime layout of `Index<Element>` is the same as `Ordinal`, which is the same as `UInt`; the phantom exists purely so the compiler can distinguish `Index<Bit>` from `Index<Byte>` at type-check time. `Element: ~Copyable` widens the set of types consumers can use as tags without imposing non-copyability on the `Index<Element>` value itself.

The five direct dependencies (ordinal, cardinal, affine, comparison, tagged) are load-bearing: removing any of them breaks `Tagged<Element, Ordinal>` itself or the affine arithmetic surface (`+ Offset`, `- Index`).

## Topics

### Essentials

- <doc:Index>
- <doc:Phantom-Type-Tags>
- <doc:Tag-Convention>
- <doc:Architecture>

### Core Type

- ``Index_Primitives_Core/Index``
