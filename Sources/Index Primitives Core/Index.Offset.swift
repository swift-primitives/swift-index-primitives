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

public import Affine_Primitives
@_spi(Internal) public import Identity_Primitives

// MARK: - Index.Offset (Tagged Typealias)

extension Tagged where RawValue == Ordinal, Tag: ~Copyable {
    /// The displacement type for this index.
    ///
    /// Wraps `Affine.Discrete.Vector` to maintain phantom type safety.
    ///
    /// ## Semantic Model
    ///
    /// An offset is the result of subtracting two indices:
    /// - `index2 - index1 → offset`
    /// - `index1 + offset → index2`
    ///
    /// ## Tagged Functor
    ///
    /// As a Tagged typealias, `Index.Offset` gains:
    /// - `retag(_:)` for zero-cost cross-domain conversion
    /// - `map(_:)` for value transformation
    /// - Automatic `Equatable`, `Hashable`, `Comparable`, `Sendable` conformances
    ///
    /// ## Example
    ///
    /// ```swift
    /// let forward = Index<Bit>.Offset(5)
    /// let backward = Index<Bit>.Offset(-3)
    /// let combined = forward + backward  // Offset(2)
    ///
    /// // Cross-domain conversion via retag
    /// let byteOffset: Index<Byte>.Offset = forward.retag(Byte.self)
    /// ```
    public typealias Offset = Tagged<Tag, Affine.Discrete.Vector>
}

// MARK: - Offset from Index Conversion

extension Tagged where RawValue == Affine.Discrete.Vector, Tag: ~Copyable {
    /// Creates an offset representing the distance from zero to the given index.
    ///
    /// This explicitly encodes the assumption that the offset is measured from
    /// the zero position, making the origin clear at call sites.
    ///
    /// ## Affine Semantics
    ///
    /// An index (position) is a point in affine space, not a vector. It becomes
    /// a vector only when measured relative to an origin. This initializer makes
    /// that "from zero" assumption explicit:
    ///
    /// ```swift
    /// let index = Index<Element>(5)
    /// let offset = Index<Element>.Offset(fromZero: index)  // offset of 5 from origin
    /// ```
    ///
    /// - Parameter index: The index to convert to an offset from zero.
    @inlinable
    public init(fromZero index: Tagged<Tag, Ordinal>) {
        self.init(Affine.Discrete.Vector(Int(bitPattern: index.rawValue.rawValue)))
    }
}
