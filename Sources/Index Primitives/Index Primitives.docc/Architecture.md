# Architecture

@Metadata {
    @TitleHeading("Index Primitives")
}

The package's place in the data-structures cohort and the design rationale for its three products.

## Overview

`Index_Primitives` is the root of **Story 2 of the data-structures cohort** (`data-structures-launch-2026`): seven packages introducing typed indexing and sequences — order, **index**, sequence, collection, input, cyclic, vector. Story 1 (cardinal, ordinal, affine) shipped 2026-05-12; Story 2 builds the typed-indexing surface on top.

## Product layout

Three library products, no Standard-Library-Integration target (`Index<Element>` is itself the integration point — there is no nominal type to add stdlib conformances to):

| Product | Target | Purpose |
|---------|--------|---------|
| `Index Primitives` | `Sources/Index Primitives/` | Umbrella — re-exports Core and the upstream primitives consumers reach for. The default import for application code. |
| `Index Primitives Core` | `Sources/Index Primitives Core/` | The `Index<Element>` typealias itself — `Tagged<Element, Ordinal>` — plus the re-exports of the two upstream packages the typealias references directly. |
| `Index Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella plus the upstream test-support spine (Tagged, Ordinal, Cardinal, Affine) for downstream test consumers. |

## Why a separate package?

The owned source is one typealias. The package still earns its own repo for two reasons:

**Type-namespace anchor.** `Index<Element>` is a stable name consumers refer to across upstream churn. When `swift-tagged-primitives` renamed `.rawValue` to `.underlying` in 2026-05 the migration through this package was mechanical because the entire package is one typealias; downstream call sites kept using `Index<Bit>`, `Index<Byte>` unchanged. A standalone package gives the name a home so downstream code does not couple to whichever upstream module currently defines the underlying machinery.

**Future surface point.** Index-specific surface — `Strideable` conformance, `RandomAccessCollection` adapters, bridging code to `swift-input-primitives` — accumulates on `Index<Element>` rather than scattering across `swift-tagged-primitives` or `swift-ordinal-primitives`. The typealias is the seed; the extensions live next to it.

## Dependency closure

Five direct dependencies. Each is honest — removing any breaks `Tagged<Element, Ordinal>` itself or the affine arithmetic surface (`+ Offset`, `- Index`).

| Dependency | Why |
|------------|-----|
| ``swift-tagged-primitives`` | Provides `Tagged<Tag, Underlying>` — the type `Index<Element>` is a typealias for. |
| ``swift-ordinal-primitives`` | Provides `Ordinal` — the `Underlying` parameter of `Tagged<Element, Ordinal>`. |
| ``swift-cardinal-primitives`` | Provides `Cardinal` — the `Underlying` of `Index<Element>.Count`. |
| ``swift-affine-primitives`` | Provides `Affine.Discrete.Vector` — the `Underlying` of `Index<Element>.Offset`. |
| ``swift-comparison-primitives`` | Provides `Comparison.Protocol` — the `Comparable`-shape conformance `Ordinal` exposes. |

The umbrella product re-exports all five, so `import Index_Primitives` brings the full typed-indexing surface into scope with one import.

## Cohort siblings

Story 2 narrows to seven packages (down from the original nine; `link` and `cyclic-index` were cut from the launch narrative for zero external consumers):

- order — total / partial order modeling
- **index** — typed positions (this package)
- sequence — typed sequence protocol
- collection — typed collection protocol
- input — input/iteration adapters
- cyclic — cyclic-buffer index variants
- vector — typed vector arithmetic (uses `Index<Element>` and `Index<Element>.Offset`)

See `data-structures-launch-2026` for the cohort narrative.

## Foundation-free, no platform conditionals

The package is layer 1 (primitives). No `import Foundation`, no `#if os(…)` guards, no concurrency surface (`Actor`, `async`, `await`, `CheckedContinuation` are all absent). Embedded compatibility is heuristic-supported: the typealias inherits whatever Embedded compatibility `Tagged` and `Ordinal` provide. First-party Embedded matrix runs post-flip via the centralized CI workflow.
