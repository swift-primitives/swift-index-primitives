//
//  File.swift
//  swift-index-primitives
//
//  Created by Coen ten Thije Boonkkamp on 27/01/2026.
//

// MARK: - UnsafeRawBufferPointer + Index

extension UnsafeRawBufferPointer {
    /// Creates a buffer pointer from a start address and typed count.
    @inlinable
    public init(
        start: UnsafeRawPointer?,
        count: Index_Primitives.Index<UInt8>.Count
    ) {
        unsafe self.init(start: start, count: Int(count.rawValue))
    }

    /// Accesses the byte at the given typed index.
    @inlinable
    public subscript(
        _ index: Index_Primitives.Index<UInt8>
    ) -> UInt8 {
        unsafe self[Int(index.position.rawValue)]
    }
}
