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

extension Tagged where RawValue == Ordinal.Position, Tag: ~Copyable {
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

// MARK: - Index.Offset Extensions (API Compatibility)

extension Tagged where RawValue == Affine.Discrete.Vector, Tag: ~Copyable {

    // MARK: - Compatibility Properties

    /// The underlying vector (displacement).
    ///
    /// This property provides backward compatibility with code that used
    /// `offset.vector` on the previous nested struct implementation.
    @inlinable
    public var vector: Affine.Discrete.Vector { rawValue }

    // MARK: - Construction

    /// Creates an offset from a vector.
    @inlinable
    public init(_ vector: Affine.Discrete.Vector) {
        self.init(__unchecked: (), vector)
    }

    /// Creates an offset with the given signed value.
    @inlinable
    public init(_ rawValue: Int) {
        self.init(__unchecked: (), Affine.Discrete.Vector(rawValue))
    }

    // MARK: - Constants

    /// The zero offset (no displacement).
    @inlinable
    public static var zero: Self { Self(__unchecked: (), .zero) }

    /// The unit offset (displacement of 1).
    @inlinable
    public static var one: Self { Self(__unchecked: (), Affine.Discrete.Vector(1)) }
}

