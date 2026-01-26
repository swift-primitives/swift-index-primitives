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

public import Cardinal_Primitives

// MARK: - Index.Count

extension Tagged where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// A phantom-typed count for bounds checking.
    ///
    /// `Index<Element>.Count` wraps `Cardinal.Count` with a phantom type,
    /// preventing accidental comparison between indices and counts from
    /// different collection types.
    ///
    /// ## Type Safety
    ///
    /// ```swift
    /// let graphCount = Index<GraphTag>.Count(10)
    /// let bitCount = Index<Bit>.Count(100)
    ///
    /// let node: Index<GraphTag> = ...
    /// node < graphCount  // OK
    /// // node < bitCount  // Compile error - different phantom types
    /// ```
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let count = Index<Tag>.Count(storage.count)
    /// guard node < count else { return nil }
    /// ```
    public struct Count: Hashable, Comparable, Sendable {
        /// The underlying cardinal count.
        public let count: Cardinal.Count

        /// The raw unsigned integer value.
        @inlinable
        public var rawValue: UInt { count.rawValue }

        /// Creates a typed count from a cardinal count.
        @inlinable
        public init(_ count: Cardinal.Count) {
            self.count = count
        }

        /// Creates a typed count from an unsigned integer.
        @inlinable
        public init(_ rawValue: UInt) {
            self.count = Cardinal.Count(rawValue)
        }

        /// Creates a typed count from a signed integer.
        ///
        /// - Parameter rawValue: The count value. Must be non-negative.
        /// - Throws: `Cardinal.Count.Error.negativeSource` if negative.
        @inlinable
        public init(_ rawValue: Int) throws(Cardinal.Count.Error) {
            self.count = try Cardinal.Count(rawValue)
        }

        /// Creates a typed count without validation.
        ///
        /// - Parameter rawValue: Must be non-negative.
        /// - Warning: No validation is performed. Use only when the value
        ///   is known to be non-negative.
        @inlinable
        public init(__unchecked: Void, _ rawValue: Int) {
            self.count = Cardinal.Count(UInt(rawValue))
        }

        /// The zero count.
        @inlinable
        @_disfavoredOverload
        public static var zero: Self {
            Self(Cardinal.Count.zero)
        }

        /// The count of one.
        @inlinable
        public static var one: Self {
            Self(Cardinal.Count.one)
        }

        @inlinable
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.count == rhs.count
        }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.count < rhs.count
        }
    }
}


// MARK: - CustomStringConvertible

extension Tagged.Count: CustomStringConvertible
where RawValue == Ordinal.Position, Tag: ~Copyable {
    public var description: String {
        "Index<\(Tag.self)>.Count(\(rawValue))"
    }
}

// MARK: - Index from Count

extension Tagged where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// Creates an index from a count.
    ///
    /// This is the canonical way to create an `endIndex` from a collection's count.
    /// Since `Count` is guaranteed non-negative, no validation is needed.
    ///
    /// ```swift
    /// let count = Index<Element>.Count(10)
    /// let endIndex = Index(count)  // Index at position 10
    /// ```
    @inlinable
    public init(_ count: Self.Count) {
        self.init(__unchecked: (), Ordinal.Position(count.count))
    }

    /// Creates an index from a count in a different tag domain.
    ///
    /// This is total - Count is non-negative, so the resulting Index is valid.
    /// Use this for cross-domain conversions where the count from one domain
    /// becomes an index position in another domain.
    ///
    /// - Parameter count: A count from a different tag domain.
    @inlinable
    public init<Other: ~Copyable>(_ count: Tagged<Other, RawValue>.Count) {
        self.init(__unchecked: (), Ordinal.Position(count.count))
    }
}

// MARK: - Index < Count Comparison

/// Checks if an index is within bounds for a collection of the given count.
///
/// This is the fundamental bounds check with phantom type safety.
@inlinable
public func < <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position.rawValue < rhs.count.rawValue
}

/// Checks if an index is at or beyond the bounds.
@inlinable
public func >= <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position.rawValue >= rhs.count.rawValue
}

/// Checks if a count is greater than an index (index is in bounds).
@inlinable
public func > <Tag: ~Copyable>(lhs: Index<Tag>.Count, rhs: Index<Tag>) -> Bool {
    lhs.count.rawValue > rhs.position.rawValue
}

/// Checks if a count is at or below an index (index is out of bounds).
@inlinable
public func <= <Tag: ~Copyable>(lhs: Index<Tag>.Count, rhs: Index<Tag>) -> Bool {
    lhs.count.rawValue <= rhs.position.rawValue
}
