//
//  File.swift
//  swift-index-primitives
//
//  Created by Coen ten Thije Boonkkamp on 27/01/2026.
//

// MARK: - UnsafeMutablePointer + Index Arithmetic

/// Advances a mutable pointer by a typed index offset.
@_transparent
public func + <Pointee: ~Copyable>(
    lhs: UnsafeMutablePointer<Pointee>,
    rhs: Index<Pointee>
) -> UnsafeMutablePointer<Pointee> {
    unsafe lhs + Int(rhs.position.rawValue)
}

/// Advances a mutable pointer by a typed index offset.
@_transparent
public func + <Pointee: ~Copyable>(
    lhs: Index<Pointee>,
    rhs: UnsafeMutablePointer<Pointee>
) -> UnsafeMutablePointer<Pointee> {
    unsafe rhs + Int(lhs.position.rawValue)
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
    @inlinable @inline(__always)
    public subscript(index: Index<Pointee>) -> Pointee {
        @_transparent
        unsafeAddress {
            unsafe UnsafePointer(self + index)
        }
        @_transparent
        unsafeMutableAddress {
            unsafe self + index
        }
    }
}
