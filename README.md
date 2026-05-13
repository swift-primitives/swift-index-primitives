# Index Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A phantom-typed index primitive — `Index<Element>`, a type-safe position into a collection of `Element`, built on `Ordinal` and the `Tagged` phantom-type machinery.

`Index<Element>` distinguishes "an index into bits" from "an index into bytes" *at compile time*. Mixing the two — accidentally subscripting a byte buffer with a bit index — becomes a type error rather than a silent off-by-one bug.

---

## Quick Start

```swift
import Index_Primitives

// Distinct phantom tags per indexing domain
private enum Bit {}
private enum Byte {}

let bitIndex:  Index<Bit>  = Index(_unchecked: Ordinal(UInt(5)))
let byteIndex: Index<Byte> = Index(_unchecked: Ordinal(UInt(5)))

// bitIndex == byteIndex     // ❌ compile error — different phantom tags
bitIndex.position            // 5 — the underlying Ordinal

// Affine arithmetic: Index ± Offset → Index (translation)
let next  = try bitIndex + Index<Bit>.Offset(3)   // Index<Bit> at position 8
let diff  = next - bitIndex                       // Index<Bit>.Offset(3)

// Index<Bit>.Offset and Index<Byte>.Offset are also distinct types
// next + Index<Byte>.Offset(1)   // ❌ compile error
```

The phantom tag (`Bit`, `Byte`) is a consumer-defined private enum with no cases. It never appears at runtime, is never stored, and never copies — it only constrains which `Index<Element>` values are *allowed to mix* in arithmetic. The pattern composes with the rest of `swift-tagged-primitives`: tag types declared once are reused across `Index`, `Offset`, `Count`, and any other `Tagged<Tag, …>` typealias the consumer constructs.

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Index Primitives", package: "swift-index-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Three library products covering the typealias, its umbrella re-exports, and a Test Support target.

| Product | Target | Purpose |
|---------|--------|---------|
| `Index Primitives` | `Sources/Index Primitives/` | Umbrella — re-exports Core and the upstream primitives consumers reach for. The default import for application code. |
| `Index Primitives Core` | `Sources/Index Primitives Core/` | The `Index<Element>` typealias itself — `Tagged<Element, Ordinal>` — plus the re-exports of the two upstream packages the typealias references directly. |
| `Index Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella plus the upstream test-support spine (Tagged, Ordinal, Cardinal, Affine) for downstream test consumers. |

Foundation-free. No platform conditionals. No concurrency surface — the typealias inherits whatever sendability / copyability `Tagged<Element, Ordinal>` provides.

---

## Phantom tags are cost-free

`Element: ~Copyable` in the typealias declaration says: the phantom-tag parameter is permitted to be a noncopyable type, not that `Index<Element>` itself becomes noncopyable.

The phantom is **never stored** — the runtime layout of `Index<Element>` is the same as `Ordinal`, which is the same as `UInt`. The phantom parameter exists purely so the compiler can distinguish `Index<Bit>` from `Index<Byte>` at type-check time. Whether the phantom tag is `Copyable` or `~Copyable` does not affect the value-layer cost — it only widens the set of types consumers can use as tags.

This is the design that lets consumers reach for tag types from move-only contexts (a tag that wraps a unique resource handle, for example) without the noncopyability propagating into the `Index<Element>` value itself.

---

## Tagged composition

`Index<Element>` is `Tagged<Element, Ordinal>` at the type-checker level. Every extension declared on `Tagged<Tag, Ordinal>` — anywhere in the dep graph — is automatically visible on `Index<Element>`, so the typed-indexing surface composes from one source of truth without per-typealias bridging.

The two forms are interchangeable at type-check time: code that names `Tagged<Element, Ordinal>` directly continues to compose with code that names `Index<Element>`.

---

## Throwing successor / predecessor

`Index<Element>.successor()` and `.predecessor()` are throwing — they return `Index<Element>` or throw an `Ordinal.Error` if the underlying position cannot advance / retreat (e.g., `predecessor()` on position zero, `successor()` at `UInt.max`). The bounds check is encoded in the type system via the throwing surface; there is no infallible variant.

```swift
let zero: Index<Bit> = Index(_unchecked: Ordinal.zero)
let next = try zero.successor()           // OK — Index<Bit> at position 1
_ = try zero.predecessor()                // throws Ordinal.Error.underflow
```

If a call site can statically prove the bounds are satisfied — typically because the index was just constructed or just incremented — the convention is `try!` with a `// reason: …` comment naming the guard. The throwing surface forces the consumer to acknowledge the partiality at the call site rather than letting an off-by-one crash production.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Linux | Full support |
| Windows | Full support |
| Swift Embedded | Supported (Wasm SDK + Swift 6.4-dev nightly CI matrix passes) |

---

## Related Packages

Direct dependencies:

- [swift-ordinal-primitives](https://github.com/swift-primitives/swift-ordinal-primitives) — `Ordinal`, the non-negative position the `Index<Element>` typealias wraps.
- [swift-cardinal-primitives](https://github.com/swift-primitives/swift-cardinal-primitives) — `Cardinal`, the non-negative count `Index<Element>.Count` builds on.
- [swift-affine-primitives](https://github.com/swift-primitives/swift-affine-primitives) — `Affine.Discrete.Vector`, the signed displacement `Index<Element>.Offset` builds on.
- [swift-tagged-primitives](https://github.com/swift-primitives/swift-tagged-primitives) — `Tagged<Tag, Underlying>`, the phantom-tagging machinery `Index<Element>` is a typealias for.
- [swift-comparison-primitives](https://github.com/swift-primitives/swift-comparison-primitives) — `Comparison.Protocol`, the `Comparable`-shape conformance `Ordinal` exposes.

---

## Community

<!-- BEGIN: discussion -->
Discuss this package: [swift-institute/discussions/31](https://github.com/orgs/swift-institute/discussions/31)
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
