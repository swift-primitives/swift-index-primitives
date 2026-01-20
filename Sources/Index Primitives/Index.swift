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

/// A typed index representing a position in a collection of `Element`.
///
/// `Index<T>` provides type-safe positions parameterized by what they index into.
/// This enables collections to specialize storage based on the index type.
///
/// ## Type Safety
///
/// Different index types cannot be confused at compile time:
///
/// ```swift
/// let bitIndex: Index<Bit> = 42
/// let byteIndex: Index<UInt8> = 42
/// // bitIndex == byteIndex  // Does not compile - different types
/// ```
///
/// ## Typed Arithmetic
///
/// Index supports typed arithmetic with `Index.Offset`:
///
/// ```swift
/// let idx = try Index<Bit>(5)
/// let offset = Index<Bit>.Offset(3)
/// let newIdx = try idx + offset  // Index<Bit>(8)
/// let distance = newIdx - idx    // Index<Bit>.Offset(3)
/// ```
///
/// ## Usage
///
/// ```swift
/// let idx = try Index<Bit>(5)
/// let idx2 = Index<Bit>(__unchecked: 10)  // Unchecked
/// idx < idx2  // true
/// ```
public struct Index<Element: ~Copyable>: Hashable, Comparable, Sendable {
    /// The position value.
    public let position: Int

    /// Creates an index at the given position.
    ///
    /// - Parameter position: The position value. Must be non-negative.
    /// - Throws: `Index.Error.negativePosition` if `position < 0`.
    @inlinable
    public init(_ position: Int) throws(Index<Element>.Error) {
        guard position >= 0 else { throw .negativePosition(position) }
        self.position = position
    }

    /// Creates an index without bounds checking.
    ///
    /// - Parameter position: Must be non-negative.
    /// - Warning: No validation is performed. Use only when the value
    ///   is known to be non-negative.
    @inlinable
    public init(__unchecked position: Int) {
        self.position = position
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.position < rhs.position
    }
}

// MARK: - ExpressibleByIntegerLiteral
//
// Index intentionally does NOT conform to ExpressibleByIntegerLiteral.
//
// The checked initializer `init(_ position: Int)` throws for negative values,
// and ExpressibleByIntegerLiteral requires a non-throwing initializer.
//
// To create an index:
// - Checked: `try Index<T>(5)` - throws if negative
// - Unchecked: `Index<T>(__unchecked: 5)` - caller guarantees non-negative

extension Index: CustomStringConvertible where Element: ~Copyable {
    public var description: String {
        "Index<\(Element.self)>(\(position))"
    }
}

// MARK: - Offset

extension Index where Element: ~Copyable {
    /// A signed offset between indices of the same type.
    ///
    /// Represents the directed distance between two indices. The sign
    /// indicates direction: positive offsets move forward (toward higher
    /// indices), negative offsets move backward.
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
    /// let forward: Index<Bit>.Offset = 5
    /// let backward: Index<Bit>.Offset = -3
    /// let combined = forward + backward  // Offset(2)
    /// ```
    public struct Offset: Hashable, Comparable, Sendable {
        /// The underlying signed value.
        public let rawValue: Int

        /// Creates an offset with the given signed value.
        @inlinable
        public init(_ rawValue: Int) {
            self.rawValue = rawValue
        }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

extension Index.Offset: ExpressibleByIntegerLiteral where Element: ~Copyable {
    @inlinable
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Index.Offset: CustomStringConvertible where Element: ~Copyable {
    public var description: String {
        "Index<\(Element.self)>.Offset(\(rawValue))"
    }
}
