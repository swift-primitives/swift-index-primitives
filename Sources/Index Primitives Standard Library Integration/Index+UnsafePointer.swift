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

// MARK: - UnsafePointer + Index<T>.Offset Arithmetic
//
// Affine arithmetic: pointer (point) + offset (vector) = pointer (point)
// This is mathematically correct - we add a displacement to a position.

/// Advances a pointer by a typed element offset.
@_transparent
public func + <Pointee: ~Copyable>(
    lhs: UnsafePointer<Pointee>,
    rhs: Index<Pointee>.Offset
) -> UnsafePointer<Pointee> {
    unsafe lhs.advanced(by: Int(rhs.rawValue.rawValue))
}

/// Advances a pointer by a typed element offset.
@_transparent
public func + <Pointee: ~Copyable>(
    lhs: Index<Pointee>.Offset,
    rhs: UnsafePointer<Pointee>
) -> UnsafePointer<Pointee> {
    unsafe rhs.advanced(by: Int(lhs.rawValue.rawValue))
}

/// Retreats a pointer by a typed element offset.
@_transparent
public func - <Pointee: ~Copyable>(
    lhs: UnsafePointer<Pointee>,
    rhs: Index<Pointee>.Offset
) -> UnsafePointer<Pointee> {
    unsafe lhs.advanced(by: -Int(rhs.rawValue.rawValue))
}

/// Computes the typed element distance between two pointers.
@_transparent
public func - <Pointee: ~Copyable>(
    lhs: UnsafePointer<Pointee>,
    rhs: UnsafePointer<Pointee>
) -> Index<Pointee>.Offset {
    Index<Pointee>.Offset(Affine.Discrete.Vector(unsafe rhs.distance(to: lhs)))
}

// MARK: - UnsafePointer Subscript

extension UnsafePointer where Pointee: ~Copyable {
    /// Accesses the element at the given typed index.
    ///
    /// This subscript enables type-safe pointer access using `Index<Pointee>`:
    ///
    /// ```swift
    /// (.zero..<count).forEach { idx in
    ///     print(elements[idx])  // idx is Index<Element>
    /// }
    /// ```
    ///
    /// - Parameter index: A typed index into the pointer's memory.
    /// - Returns: The element at the specified index.
    /// - Note: Converts index to offset from zero: `self + (index - .zero)`.
    @inlinable @inline(__always)
    public subscript(index: Index<Pointee>) -> Pointee {
        @_transparent
        unsafeAddress {
            // Affine: point + (point - origin) = point + vector
            unsafe self + Index.Offset(__unchecked: (), index)
        }
    }
}
