# Architecture

@Metadata {
    @TitleHeading("Index Primitives")
}

The package's product layout and the design rationale for its three products.

## Product layout

Three library products, no Standard-Library-Integration target (`Index<Element>` is itself the integration point — there is no nominal type to add stdlib conformances to):

| Product | Target | Purpose |
|---------|--------|---------|
| `Index Primitives` | `Sources/Index Primitives/` | Umbrella — re-exports Core and the upstream primitives consumers reach for. The default import for application code. |
| `Index Primitives Core` | `Sources/Index Primitives Core/` | The `Index<Element>` typealias itself — `Tagged<Element, Ordinal>` — plus the re-exports of the two upstream packages the typealias references directly. |
| `Index Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella plus the upstream test-support spine (Tagged, Ordinal, Cardinal, Affine) for downstream test consumers. |

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

## Foundation-free, no platform conditionals

No `import Foundation`, no `#if os(…)` guards, no concurrency surface (`Actor`, `async`, `await`, `CheckedContinuation` are all absent). The typealias inherits whatever Embedded compatibility `Tagged` and `Ordinal` provide; the Wasm SDK build and Swift 6.4-dev nightly Embedded matrix both pass in CI.
