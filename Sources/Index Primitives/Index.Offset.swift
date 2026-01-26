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

// MARK: - Index.Offset

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
    /// ## Example
    ///
    /// ```swift
    /// let forward = Index<Bit>.Offset(5)
    /// let backward = Index<Bit>.Offset(-3)
    /// let combined = forward + backward  // Offset(2)
    /// ```
    public struct Offset: Hashable, Comparable, Sendable {
        /// The underlying vector (displacement).
        public let vector: Affine.Discrete.Vector

        /// Creates an offset from a vector.
        @inlinable
        public init(_ vector: Affine.Discrete.Vector) {
            self.vector = vector
        }

        /// Creates an offset with the given signed value.
        @inlinable
        public init(_ rawValue: Int) {
            self.vector = Affine.Discrete.Vector(rawValue)
        }

        /// The underlying signed value.
        @inlinable
        public var rawValue: Int { vector.rawValue }

        /// The zero offset (no displacement).
        @inlinable
        public static var zero: Self { Self(0) }

        /// The unit offset (displacement of 1).
        @inlinable
        public static var one: Self { Self(1) }

        @inlinable
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.vector == rhs.vector
        }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.vector < rhs.vector
        }
    }
}
