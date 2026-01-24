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

// MARK: - Index.Count

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// A phantom-typed count for bounds checking.
    ///
    /// `Index<Element>.Count` wraps `Affine.Discrete.Count` with a phantom type,
    /// preventing accidental comparison between indices and counts from
    /// different collection types.
    ///
    /// ## Type Safety
    ///
    /// ```swift
    /// let graphCount: Index<GraphTag>.Count = 10
    /// let bitCount: Index<Bit>.Count = 100
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
        /// The underlying untyped count.
        public let count: Affine.Discrete.Count

        /// The raw integer value.
        @inlinable
        public var rawValue: Int { count.rawValue }

        /// Creates a typed count from an untyped count.
        @inlinable
        public init(_ count: Affine.Discrete.Count) {
            self.count = count
        }

        /// Creates a typed count from an integer.
        ///
        /// - Parameter rawValue: The count value. Must be non-negative.
        /// - Throws: `Affine.Discrete.Count.Error.negativeValue` if negative.
        @inlinable
        public init(_ rawValue: Int) throws(Affine.Discrete.Count.Error) {
            self.count = try Affine.Discrete.Count(rawValue)
        }

        /// Creates a typed count without validation.
        ///
        /// - Parameter rawValue: Must be non-negative.
        @inlinable
        public init(__unchecked rawValue: Int) {
            self.count = Affine.Discrete.Count(__unchecked: rawValue)
        }

        /// The zero count.
        @inlinable
        public static var zero: Self {
            Self(Affine.Discrete.Count.zero)
        }
        
        /// The zero count.
        @inlinable
        public static var one: Self {
            Self(Affine.Discrete.Count.one)
        }
        
        /// The zero count.
        @inlinable
        public static var two: Self {
            Self(Affine.Discrete.Count.two)
        }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.count < rhs.count
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Tagged.Count: ExpressibleByIntegerLiteral
where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    @inlinable
    public init(integerLiteral value: Int) {
        self.count = Affine.Discrete.Count(integerLiteral: value)
    }
}

// MARK: - CustomStringConvertible

extension Tagged.Count: CustomStringConvertible
where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    public var description: String {
        "Index<\(Tag.self)>.Count(\(rawValue))"
    }
}

// MARK: - Index from Count

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Creates an index from a count.
    ///
    /// This is the canonical way to create an `endIndex` from a collection's count.
    /// Since `Count` is guaranteed non-negative, no validation is needed.
    ///
    /// ```swift
    /// let count: Index<Element>.Count = 10
    /// let endIndex = Index(count)  // Index at position 10
    /// ```
    @inlinable
    public init(_ count: Self.Count) {
        self.init(__unchecked: (), position: count.rawValue)
    }
}

// MARK: - Index < Count Comparison

/// Checks if an index is within bounds for a collection of the given count.
///
/// This is the fundamental bounds check with phantom type safety.
@inlinable
public func < <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position < rhs.count
}

/// Checks if an index is at or beyond the bounds.
@inlinable
public func >= <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position >= rhs.count
}

/// Checks if a count is greater than an index (index is in bounds).
@inlinable
public func > <Tag: ~Copyable>(lhs: Index<Tag>.Count, rhs: Index<Tag>) -> Bool {
    lhs.count > rhs.position
}

/// Checks if a count is at or below an index (index is out of bounds).
@inlinable
public func <= <Tag: ~Copyable>(lhs: Index<Tag>.Count, rhs: Index<Tag>) -> Bool {
    lhs.count <= rhs.position
}
