//
//  Index+UnsafeMutableRawBufferPointer.swift
//  swift-index-primitives
//
//  Created by Coen ten Thije Boonkkamp on 27/01/2026.
//

// MARK: - UnsafeMutableRawBufferPointer + Index

extension UnsafeMutableRawBufferPointer {
    /// Creates a mutable buffer pointer from a start address and typed count.
    @inlinable
    public init(
        start: UnsafeMutableRawPointer?,
        count: Index_Primitives_Core.Index<UInt8>.Count
    ) {
        unsafe self.init(start: start, count: Int(count.count.rawValue))
    }

    /// Allocates uninitialized memory with typed count and alignment.
    @inlinable
    public static func allocate(
        count: Index_Primitives_Core.Index<UInt8>.Count,
        alignment: Index_Primitives_Core.Index<UInt8>.Count
    ) -> Self {
        Self.allocate(byteCount: Int(count.count.rawValue), alignment: Int(alignment.count.rawValue))
    }

    /// Accesses the byte at the given typed index.
    @inlinable
    public subscript(
        _ index: Index_Primitives_Core.Index<UInt8>
    ) -> UInt8 {
        get { unsafe self[Int(index.position.rawValue)] }
        nonmutating set { unsafe self[Int(index.position.rawValue)] = newValue }
    }

    /// Returns a new instance of the given type, read from the specified offset.
    ///
    /// - Parameters:
    ///   - offset: The offset from the start of the buffer at which to read.
    ///   - type: The type of the value to read.
    /// - Returns: A new instance of the given type.
    @inlinable
    public func load<T>(
        fromByteOffset offset: Index_Primitives_Core.Index<UInt8>.Offset,
        as type: T.Type
    ) -> T {
        unsafe self.load(fromByteOffset: offset.vector.rawValue, as: type)
    }
}
