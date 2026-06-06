// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Ordinal_Primitives
@_spi(Internal) public import Tagged_Primitives

// `Index<Element>.Bounded<N>` — the §5.3 typed-bounded-index home (calculus
// `decomposition-layer-placement-calculus.md`; package-map §A.3 / §C.2 item 11).
//
// `Index<Element>` is a typealias `Tagged<Element, Ordinal>`, so `.Bounded<N>` is attached
// to the Tagged-as-Index instantiation via a constrained extension — exactly as
// `Index<Element>.Offset` / `.Count` are (affine/ordinal-primitives). The spelling
// `Index<Element>.Bounded<N>` then resolves naturally.
extension Tagged where Underlying == Ordinal, Tag: ~Copyable & ~Escapable {
    /// A **capacity-bounded** index: a position proven to lie in `0..<N`, with the bound `N`
    /// carried at the type level.
    ///
    /// This is the index axis's answer to static capacity (`[IMPL-050]`): a static-capacity
    /// collection (`let N: Int`) accepts `Index<Element>.Bounded<N>` in its positional APIs so
    /// the *bound* is proven by the type and the collection's API need only prove *occupancy*.
    /// It is a sibling of `Index<Element>.Offset` / `.Count` on the same `Tagged`-as-`Index`
    /// instantiation.
    @frozen
    public struct Bounded<let N: Int> {
        /// The position. The invariant `0 <= position < N` holds for any value built via the
        /// checked initializers (`init(_:)` / integer literal); `init(_unchecked:)` delegates the
        /// guarantee to the caller.
        public let position: Tagged<Tag, Ordinal>

        /// The compile-time capacity bound, `N`.
        @inlinable
        public static var capacity: Int { N }

        /// Wraps a position **without** bounds-checking; the caller guarantees `0 <= position < N`.
        @inlinable
        public init(_unchecked position: Tagged<Tag, Ordinal>) {
            self.position = position
        }

        /// Creates a bounded index from a raw position, trapping if it is outside `0..<N`.
        ///
        /// - Precondition: `0 <= position && position < N`.
        @inlinable
        public init(_ position: Int) {
            precondition(
                position >= 0 && position < N,
                "Index.Bounded<\(N)>: position \(position) is out of bounds 0..<\(N)"
            )
            self.position = Tagged(_unchecked: Ordinal(UInt(position)))
        }
    }
}

extension Tagged.Bounded: ExpressibleByIntegerLiteral
where Underlying == Ordinal, Tag: ~Copyable & ~Escapable {
    /// Literal construction, e.g. `let pos: Index<Element>.Bounded<16> = 0` (`[IMPL-050]`).
    /// Traps on a literal outside `0..<N`.
    @inlinable
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
