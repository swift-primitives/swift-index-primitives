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

// MARK: - UnsafeMutablePointer + Index Arithmetic

/// Advances a mutable pointer by a typed index offset.
@inlinable
public func + <Pointee: ~Copyable>(
    lhs: UnsafeMutablePointer<Pointee>,
    rhs: Index<Pointee>
) -> UnsafeMutablePointer<Pointee> {
    unsafe lhs + rhs.position.rawValue
}

/// Advances a mutable pointer by a typed index offset.
@inlinable
public func + <Pointee: ~Copyable>(
    lhs: Index<Pointee>,
    rhs: UnsafeMutablePointer<Pointee>
) -> UnsafeMutablePointer<Pointee> {
    unsafe rhs + lhs.position.rawValue
}

// MARK: - UnsafePointer + Index Arithmetic

/// Advances a pointer by a typed index offset.
@inlinable
public func + <Pointee: ~Copyable>(
    lhs: UnsafePointer<Pointee>,
    rhs: Index<Pointee>
) -> UnsafePointer<Pointee> {
    unsafe lhs + rhs.position.rawValue
}

/// Advances a pointer by a typed index offset.
@inlinable
public func + <Pointee: ~Copyable>(
    lhs: Index<Pointee>,
    rhs: UnsafePointer<Pointee>
) -> UnsafePointer<Pointee> {
    unsafe rhs + lhs.position.rawValue
}

// MARK: - UnsafeMutablePointer Subscript

extension UnsafeMutablePointer where Pointee: ~Copyable {
    /// Accesses the element at the given typed index.
    ///
    /// This subscript enables type-safe pointer access using `Index<Pointee>`:
    ///
    /// ```swift
    /// (0..<count).forEach { i in
    ///     body(elements[i])  // i is Index<Element>
    /// }
    /// ```
    ///
    /// - Parameter index: A typed index into the pointer's memory.
    /// - Returns: The element at the specified index.
    @inlinable
    public subscript(index: Index<Pointee>) -> Pointee {
        @inline(__always)
        unsafeAddress {
            unsafe UnsafePointer(self + index)
        }
        @inline(__always)
        unsafeMutableAddress {
            unsafe self + index
        }
    }
}

// MARK: - UnsafePointer Subscript

extension UnsafePointer where Pointee: ~Copyable {
    /// Accesses the element at the given typed index.
    ///
    /// This subscript enables type-safe pointer access using `Index<Pointee>`:
    ///
    /// ```swift
    /// (0..<count).forEach { i in
    ///     print(elements[i])  // i is Index<Element>
    /// }
    /// ```
    ///
    /// - Parameter index: A typed index into the pointer's memory.
    /// - Returns: The element at the specified index.
    @inlinable
    public subscript(index: Index<Pointee>) -> Pointee {
        @inline(__always)
        unsafeAddress {
            unsafe self + index
        }
    }
}
