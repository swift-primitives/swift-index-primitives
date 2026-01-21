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

// MARK: - Index + Offset → Index? (Point + Vector → Point)

/// Advances an index by an offset.
///
/// - Returns: The new index, or `nil` if the result would be negative.
@inlinable
public func + <Element: ~Copyable>(
    lhs: Index<Element>,
    rhs: Index<Element>.Offset
) -> Index<Element>? {
    (lhs.position + rhs.displacement).map { Index($0) }
}

/// Advances an index by an offset (commutative).
///
/// - Returns: The new index, or `nil` if the result would be negative.
@inlinable
public func + <Element: ~Copyable>(
    lhs: Index<Element>.Offset,
    rhs: Index<Element>
) -> Index<Element>? {
    (lhs.displacement + rhs.position).map { Index($0) }
}

// MARK: - Index - Offset → Index? (Point - Vector → Point)

/// Retreats an index by an offset.
///
/// - Returns: The new index, or `nil` if the result would be negative.
@inlinable
public func - <Element: ~Copyable>(
    lhs: Index<Element>,
    rhs: Index<Element>.Offset
) -> Index<Element>? {
    (lhs.position - rhs.displacement).map { Index($0) }
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
    Index<Element>.Offset(lhs.displacement + rhs.displacement)
}

/// Subtracts two offsets.
@inlinable
public func - <Element: ~Copyable>(
    lhs: Index<Element>.Offset,
    rhs: Index<Element>.Offset
) -> Index<Element>.Offset {
    Index<Element>.Offset(lhs.displacement - rhs.displacement)
}

/// Negates an offset.
@inlinable
public prefix func - <Element: ~Copyable>(
    offset: Index<Element>.Offset
) -> Index<Element>.Offset {
    Index<Element>.Offset(-offset.displacement)
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
