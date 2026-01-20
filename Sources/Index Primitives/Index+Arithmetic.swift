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

// MARK: - Index + Offset → Index

/// Advances an index by an offset.
///
/// - Throws: `Index.Error.negativePosition` if the result would be negative.
@inlinable
public func + <Element: ~Copyable>(lhs: Index<Element>, rhs: Index<Element>.Offset) throws(Index<Element>.Error) -> Index<Element> {
    try Index<Element>(lhs.position + rhs.rawValue)
}

/// Advances an index by an offset (commutative).
///
/// - Throws: `Index.Error.negativePosition` if the result would be negative.
@inlinable
public func + <Element: ~Copyable>(lhs: Index<Element>.Offset, rhs: Index<Element>) throws(Index<Element>.Error) -> Index<Element> {
    try Index<Element>(lhs.rawValue + rhs.position)
}

/// Retreats an index by an offset.
///
/// - Throws: `Index.Error.negativePosition` if the result would be negative.
@inlinable
public func - <Element: ~Copyable>(lhs: Index<Element>, rhs: Index<Element>.Offset) throws(Index<Element>.Error) -> Index<Element> {
    try Index<Element>(lhs.position - rhs.rawValue)
}

// MARK: - Index - Index → Offset

/// Returns the signed offset between two indices.
///
/// The result is positive if `lhs > rhs`, negative if `lhs < rhs`.
@inlinable
public func - <Element: ~Copyable>(lhs: Index<Element>, rhs: Index<Element>) -> Index<Element>.Offset {
    Index<Element>.Offset(lhs.position - rhs.position)
}

// MARK: - Offset ± Offset → Offset

/// Adds two offsets.
@inlinable
public func + <Element: ~Copyable>(lhs: Index<Element>.Offset, rhs: Index<Element>.Offset) -> Index<Element>.Offset {
    Index<Element>.Offset(lhs.rawValue + rhs.rawValue)
}

/// Subtracts two offsets.
@inlinable
public func - <Element: ~Copyable>(lhs: Index<Element>.Offset, rhs: Index<Element>.Offset) -> Index<Element>.Offset {
    Index<Element>.Offset(lhs.rawValue - rhs.rawValue)
}

/// Negates an offset.
@inlinable
public prefix func - <Element: ~Copyable>(offset: Index<Element>.Offset) -> Index<Element>.Offset {
    Index<Element>.Offset(-offset.rawValue)
}

// MARK: - Compound Assignment

/// Advances an index by an offset in place.
///
/// - Throws: `Index.Error.negativePosition` if the result would be negative.
@inlinable
public func += <Element: ~Copyable>(lhs: inout Index<Element>, rhs: Index<Element>.Offset) throws(Index<Element>.Error) {
    lhs = try lhs + rhs
}

/// Retreats an index by an offset in place.
///
/// - Throws: `Index.Error.negativePosition` if the result would be negative.
@inlinable
public func -= <Element: ~Copyable>(lhs: inout Index<Element>, rhs: Index<Element>.Offset) throws(Index<Element>.Error) {
    lhs = try lhs - rhs
}

/// Adds an offset to another offset in place.
@inlinable
public func += <Element: ~Copyable>(lhs: inout Index<Element>.Offset, rhs: Index<Element>.Offset) {
    lhs = lhs + rhs
}

/// Subtracts an offset from another offset in place.
@inlinable
public func -= <Element: ~Copyable>(lhs: inout Index<Element>.Offset, rhs: Index<Element>.Offset) {
    lhs = lhs - rhs
}
