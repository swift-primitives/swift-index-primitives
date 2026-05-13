# Index Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A phantom-typed index primitive — `Index<Element>`, a type-safe position into a collection of `Element`, built on `Ordinal` and the `Tagged` phantom-type machinery.

`Index<Element>` distinguishes "an index into bits" from "an index into bytes" *at compile time*. Mixing the two — accidentally subscripting a byte buffer with a bit index — becomes a type error rather than a silent off-by-one bug.

This package is the root of **Story 2 of the data-structures cohort** (`data-structures-launch-2026`): seven packages introducing typed indexing and sequences — order, **index**, sequence, collection, input, cyclic, vector. Story 1 (cardinal, ordinal, affine) shipped 2026-05-12.

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

## Why a separate package?

`Index<Element>` is a one-line typealias — `public typealias Index<Element: ~Copyable> = Tagged<Element, Ordinal>` — but it earns its own package for two reasons.

**Type-namespace anchor.** `Index<Element>` is a stable name consumers refer to across upstream churn. When `swift-tagged-primitives` renamed `.rawValue` to `.underlying` in 2026-05 the migration through this package was mechanical because the entire package is one typealias; downstream call sites kept using `Index<Bit>`, `Index<Byte>` unchanged. A standalone package gives the name a home so downstream code does not couple to whichever upstream module currently defines the underlying machinery.

**Future surface point.** Index-specific surface — `Strideable` conformance, `RandomAccessCollection` adapters, bridging code to `swift-input-primitives` — accumulates on `Index<Element>` rather than scattering across `swift-tagged-primitives` or `swift-ordinal-primitives`. Today the typealias is the whole package; tomorrow the typealias is the seed and the extensions live next to it.

The five direct dependencies (ordinal, cardinal, affine, comparison, tagged) are honest: removing any of them breaks `Tagged<Element, Ordinal>` itself or the affine arithmetic surface (`+ Offset`, `- Index`). The package re-exports them so a single `import Index_Primitives` brings the full typed-indexing surface into scope.

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

## Why a typealias, not a struct?

A `public struct Index<Element>` with `let position: Ordinal` would give a nominal type with its own ABI surface and extension namespace. The package ships a typealias to `Tagged<Element, Ordinal>` instead because the alternative is denser, not lighter.

Every extension declared on `Tagged<Tag, Ordinal>` — anywhere in the dep graph — is automatically visible on `Index<Element>`. The cohort's typed-indexing narrative composes from one source of truth (`Tagged<Tag, Underlying>`) without rewriting extension code per typealias. A nominal struct would require manual bridging for each `Tagged`-flavored extension; the typealias gets the bridging for free.

The trade-off is intentional: source-level identity (`Index<Element>` and `Tagged<Element, Ordinal>` are interchangeable at type-check time) in exchange for cost-free composition with the rest of the Tagged ecosystem. The `Research/Strideable Index Design.md` and `Research/index-count-spelling.md` design docs spell out the comparison against the struct alternative.

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
| Linux | Full support (post-flip CI matrix) |
| Windows | Full support (post-flip CI matrix) |
| Swift Embedded | Heuristic-supported (no Foundation, no concurrency surface) — verified through upstream Tagged / Ordinal Embedded coverage; first-party Embedded matrix runs post-flip |

---

## Related Packages

Direct dependencies (all already-public):

- [swift-ordinal-primitives](https://github.com/swift-primitives/swift-ordinal-primitives) — `Ordinal`, the non-negative position the `Index<Element>` typealias wraps.
- [swift-cardinal-primitives](https://github.com/swift-primitives/swift-cardinal-primitives) — `Cardinal`, the non-negative count `Index<Element>.Count` builds on.
- [swift-affine-primitives](https://github.com/swift-primitives/swift-affine-primitives) — `Affine.Discrete.Vector`, the signed displacement `Index<Element>.Offset` builds on.
- [swift-tagged-primitives](https://github.com/swift-primitives/swift-tagged-primitives) — `Tagged<Tag, Underlying>`, the phantom-tagging machinery `Index<Element>` is a typealias for.
- [swift-comparison-primitives](https://github.com/swift-primitives/swift-comparison-primitives) — `Comparison.Protocol`, the `Comparable`-shape conformance `Ordinal` exposes.

Cohort siblings (Story 2 — Typed indexing and sequences):

- order, **index**, sequence, collection, input, cyclic, vector — see [`data-structures-launch-2026`](https://github.com/swift-institute) for the cohort narrative.

---

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
