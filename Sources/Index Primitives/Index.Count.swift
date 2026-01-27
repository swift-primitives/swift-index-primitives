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

// MARK: - Index.Count (Tagged Typealias)

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
    /// ## Tagged Functor
    ///
    /// As a Tagged typealias, `Index.Count` gains:
    /// - `retag(_:)` for zero-cost cross-domain conversion
    /// - `map(_:)` for value transformation
    /// - Automatic `Equatable`, `Hashable`, `Comparable`, `Sendable` conformances
    ///
    /// ```swift
    /// // Cross-domain conversion via retag
    /// let rangeCount: Index<Range>.Count = ...
    /// let elementCount: Index<Element>.Count = rangeCount.retag(Element.self)
    ///
    /// // Value transformation via map
    /// let doubled = count.map { Cardinal.Count($0.rawValue * 2) }
    /// ```
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let count = Index<Tag>.Count(storage.count)
    /// guard node < count else { return nil }
    /// ```
    public typealias Count = Tagged<Tag, Cardinal.Count>
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
        self.init(__unchecked: (), Ordinal.Position(count.rawValue))
    }

    /// Creates an index from a count in a different tag domain.
    ///
    /// This is total - Count is non-negative, so the resulting Index is valid.
    /// Use this for cross-domain conversions where the count from one domain
    /// becomes an index position in another domain.
    ///
    /// - Parameter count: A count from a different tag domain.
    @inlinable
    public init<Other: ~Copyable>(_ count: Tagged<Other, Cardinal.Count>) {
        self.init(__unchecked: (), Ordinal.Position(count.rawValue))
    }
}

// MARK: - Count from Index

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {
    /// Creates a count from an index position.
    ///
    /// Semantically, position N means "N elements precede this position",
    /// so the count equals the position's numeric value.
    ///
    /// ```swift
    /// let index = Index<Element>(5)
    /// let count = Index<Element>.Count(index)  // Count of 5
    /// ```
    @inlinable
    public init(_ index: Tagged<Tag, Ordinal.Position>) {
        self.init(__unchecked: (), Cardinal.Count(index.rawValue.rawValue))
    }

    /// Creates a count from an index in a different tag domain.
    @inlinable
    public init<Other: ~Copyable>(_ index: Tagged<Other, Ordinal.Position>) {
        self.init(__unchecked: (), Cardinal.Count(index.rawValue.rawValue))
    }
}

// MARK: - Index < Count Comparison

/// Checks if an index is within bounds for a collection of the given count.
///
/// This is the fundamental bounds check with phantom type safety.
@inlinable
public func < <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position.rawValue < rhs.rawValue.rawValue
}

/// Checks if an index is at or beyond the bounds.
@inlinable
public func >= <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position.rawValue >= rhs.rawValue.rawValue
}

/// Checks if a count is greater than an index (index is in bounds).
@inlinable
public func > <Tag: ~Copyable>(lhs: Index<Tag>.Count, rhs: Index<Tag>) -> Bool {
    lhs.rawValue.rawValue > rhs.position.rawValue
}

/// Checks if a count is at or below an index (index is out of bounds).
@inlinable
public func <= <Tag: ~Copyable>(lhs: Index<Tag>.Count, rhs: Index<Tag>) -> Bool {
    lhs.rawValue.rawValue <= rhs.position.rawValue
}

/// Checks if an index is a valid endpoint (at or before count).
///
/// Unlike `<`, this allows `index == count` which represents the one-past-end
/// position — valid for range endpoints and slice bounds, but not for subscript access.
@inlinable
public func <= <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position.rawValue <= rhs.rawValue.rawValue
}

/// Checks if an index is strictly past the end.
@inlinable
public func > <Tag: ~Copyable>(lhs: Index<Tag>, rhs: Index<Tag>.Count) -> Bool {
    lhs.position.rawValue > rhs.rawValue.rawValue
}
