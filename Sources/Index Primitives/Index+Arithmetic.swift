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

// Index Affine Arithmetic
//
// Index follows affine space semantics from category theory:
// - Index is a "point" in 1D discrete affine space
// - Offset is a "vector" (displacement between points)
//
// Affine operations:
// - Point - Point → Vector (displacement)
// - Point + Vector → Point (translation)
// - Point - Vector → Point (translation)
// - Vector + Vector → Vector (vector addition)
// - Point + Point → undefined (intentionally unsupported)

// MARK: - Index + Offset → Index (Point + Vector → Point)

/// Advances an index by an offset.
///
/// - Throws: `Ordinal.Position.Error.negativeSource` if the result would be negative.
@inlinable
public func + <Element: ~Copyable>(
    lhs: Index<Element>,
    rhs: Index<Element>.Offset
) throws(Ordinal.Position.Error) -> Index<Element> {
    let result = Int(bitPattern: lhs.position.rawValue) + rhs.rawValue
    guard result >= .zero else {
        throw .negativeSource(result)
    }
    return Index(__unchecked: (), Ordinal.Position(UInt(result)))
}

/// Advances an index by an offset (commutative).
///
/// - Throws: `Ordinal.Position.Error.negativeSource` if the result would be negative.
@inlinable
public func + <Element: ~Copyable>(
    lhs: Index<Element>.Offset,
    rhs: Index<Element>
) throws(Ordinal.Position.Error) -> Index<Element> {
    try rhs + lhs
}

// MARK: - Index - Offset → Index (Point - Vector → Point)

/// Retreats an index by an offset.
///
/// - Throws: `Ordinal.Position.Error.negativeSource` if the result would be negative.
@inlinable
public func - <Element: ~Copyable>(
    lhs: Index<Element>,
    rhs: Index<Element>.Offset
) throws(Ordinal.Position.Error) -> Index<Element> {
    let result = Int(bitPattern: lhs.position.rawValue) - rhs.rawValue
    guard result >= 0 else {
        throw .negativeSource(result)
    }
    return Index(__unchecked: (), Ordinal.Position(UInt(result)))
}

// MARK: - Index - Index → Offset (Point - Point → Vector)

/// Returns the signed offset (displacement) between two indices.
///
/// The result is positive if `lhs > rhs`, negative if `lhs < rhs`.
/// This is the fundamental affine operation: point difference yields a vector.
@inlinable
public func - <Element: ~Copyable>(
    lhs: Index<Element>,
    rhs: Index<Element>
) -> Index<Element>.Offset {
    Index<Element>.Offset(lhs.position - rhs.position)
}

// MARK: - Offset ± Offset → Offset (Vector ± Vector → Vector)

/// Adds two offsets (vector addition).
@inlinable
public func + <Element: ~Copyable>(
    lhs: Index<Element>.Offset,
    rhs: Index<Element>.Offset
) -> Index<Element>.Offset {
    Index<Element>.Offset(lhs.vector + rhs.vector)
}

/// Subtracts two offsets.
@inlinable
public func - <Element: ~Copyable>(
    lhs: Index<Element>.Offset,
    rhs: Index<Element>.Offset
) -> Index<Element>.Offset {
    Index<Element>.Offset(lhs.vector - rhs.vector)
}

/// Negates an offset.
@inlinable
public prefix func - <Element: ~Copyable>(
    offset: Index<Element>.Offset
) -> Index<Element>.Offset {
    Index<Element>.Offset(-offset.vector)
}

// MARK: - Compound Assignment

/// Adds an offset to another offset in place.
@inlinable
public func += <Element: ~Copyable>(
    lhs: inout Index<Element>.Offset,
    rhs: Index<Element>.Offset
) {
    lhs = lhs + rhs
}

/// Subtracts an offset from another offset in place.
@inlinable
public func -= <Element: ~Copyable>(
    lhs: inout Index<Element>.Offset,
    rhs: Index<Element>.Offset
) {
    lhs = lhs - rhs
}

// MARK: - Index ±= Offset (Compound Assignment)

/// Advances an index by an offset in place.
///
/// - Throws: `Ordinal.Position.Error.negativeSource` if the result would be negative.
@inlinable
public func += <Element: ~Copyable>(
    lhs: inout Index<Element>,
    rhs: Index<Element>.Offset
) throws(Ordinal.Position.Error) {
    lhs = try lhs + rhs
}

/// Retreats an index by an offset in place.
///
/// - Throws: `Ordinal.Position.Error.negativeSource` if the result would be negative.
@inlinable
public func -= <Element: ~Copyable>(
    lhs: inout Index<Element>,
    rhs: Index<Element>.Offset
) throws(Ordinal.Position.Error) {
    lhs = try lhs - rhs
}

// MARK: - Index % Count → Index (Modular Projection)

/// Projects an index position into a bounded range.
///
/// This is the canonical operation for ring buffer wrap-around with runtime capacity:
/// ```swift
/// _storage.header.tail = try (tail + .one) % capacity
/// ```
///
/// For compile-time bounded indices, use `Index.Bounded<N>` with cyclic group
/// arithmetic (`+`, `-`) instead.
///
/// - Parameters:
///   - lhs: The index to project.
///   - rhs: The capacity (must be positive).
/// - Returns: The projected index within `[0, rhs)`.
@inlinable
public func % <Element: ~Copyable>(
    lhs: Index<Element>,
    rhs: Index<Element>.Count
) -> Index<Element> {
    Index<Element>(__unchecked: (), Ordinal.Position(lhs.position.rawValue % rhs.rawValue))
}
