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
/// ## Usage
///
/// ```swift
/// let idx = Index<Bit>(5)
/// let idx2: Index<Bit> = 10  // Integer literal
/// idx < idx2  // true
/// ```
public struct Index<Element>: Hashable, Comparable, Sendable {
    /// The position value.
    public let position: Int

    /// Creates an index at the given position.
    ///
    /// - Parameter position: The position value. Must be non-negative.
    /// - Precondition: `position >= 0`
    @inlinable
    public init(_ position: Int) {
        precondition(position >= 0, "Index position must be non-negative")
        self.position = position
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.position < rhs.position
    }
}

extension Index: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Index: CustomStringConvertible {
    public var description: String {
        "Index<\(Element.self)>(\(position))"
    }
}
