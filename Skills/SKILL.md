---
name: index-primitives
description: |
  Type-safe index primitives for collections. Phantom-typed indices prevent
  cross-collection index misuse. ALWAYS apply when working with typed indices
  or collection addressing.

layer: implementation

requires:
  - primitives
  - naming

applies_to:
  - swift
  - swift-primitives
  - swift-index-primitives
---

# Index Primitives

Type-safe phantom-typed index primitives for Swift Institute collections.

---

## Core Design Decisions

### [IDX-001] Phantom Generic Index

**Statement**: Indices MUST use phantom generics to prevent cross-collection misuse.

```swift
public typealias Index<Element: ~Copyable> = Tagged<Element, Affine.Discrete.Position>
```

The `Element` type parameter is not stored—it exists only for compile-time safety.

### [IDX-002] Affine Arithmetic Foundation

**Statement**: Index arithmetic MUST be based on affine space semantics.

| Type | Semantic | Operations |
|------|----------|------------|
| `Index<E>` | Position | + Offset → Index |
| `Index<E>.Offset` | Displacement | + Offset → Offset |
| `Index<E>.Count` | Cardinality | Magnitude only |

### [IDX-003] ~Copyable Support

**Statement**: All index types MUST support `~Copyable` element tags.

```swift
struct Container<Element: ~Copyable>: ~Copyable {
    var startIndex: Index<Element> { ... }
    var endIndex: Index<Element> { ... }
}
```

### [IDX-004] Bounded Index Variant

**Statement**: Compile-time bounded indices use value generics.

```swift
struct Index<Element: ~Copyable>.Bounded<let upperBound: Int>
```

---

## Type Hierarchy

```
Index<Element>
├── .Offset       // Displacement between positions
├── .Count        // Non-negative cardinality
└── .Bounded<N>   // Compile-time bounded variant
```

---

## Key Patterns

### Tagged Type Foundation

```swift
// Index is a type alias over Tagged
public typealias Index<Element: ~Copyable> = Tagged<Element, Affine.Discrete.Position>

// Offset and Count follow same pattern
public typealias Offset = Tagged<Element, Affine.Discrete.Displacement>
public typealias Count = Tagged<Element, Affine.Discrete.Cardinal>
```

### Safe Arithmetic

```swift
// Position + Displacement → Position
let next: Index<E> = index + offset

// Position - Position → Displacement
let distance: Index<E>.Offset = end - start

// Displacement + Displacement → Displacement
let combined: Index<E>.Offset = offset1 + offset2
```

---

## Cross-References

| Topic | Skill |
|-------|-------|
| Affine arithmetic | **affine-primitives** |
| Tagged type pattern | **identity-primitives** |
| Collection usage | **collection-primitives** |

Full architectural analysis: `Research/Architecture.md`
