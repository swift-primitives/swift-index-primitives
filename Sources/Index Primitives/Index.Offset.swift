//
//  File.swift
//  swift-index-primitives
//
//  Created by Coen ten Thije Boonkkamp on 26/01/2026.
//

public import Affine_Primitives
@_spi(Internal) public import Identity_Primitives

// MARK: - Index.Offset

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// The displacement type for this index.
    ///
    /// Wraps `Affine.Discrete.Displacement` to maintain phantom type safety.
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
        /// The underlying displacement.
        public let displacement: Affine.Discrete.Displacement

        /// Creates an offset from a displacement.
        @inlinable
        public init(_ displacement: Affine.Discrete.Displacement) {
            self.displacement = displacement
        }

        /// Creates an offset with the given signed value.
        @inlinable
        public init(_ rawValue: Int) {
            self.displacement = Affine.Discrete.Displacement(rawValue)
        }

        /// The underlying signed value.
        @inlinable
        public var rawValue: Int { displacement.rawValue }

        /// The zero offset (no displacement).
        @inlinable
        public static var zero: Self { Self(0) }

        /// The unit offset (displacement of 1).
        @inlinable
        public static var one: Self { Self(1) }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.displacement < rhs.displacement
        }
    }
}
