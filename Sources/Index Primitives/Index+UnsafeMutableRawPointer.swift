//
//  File.swift
//  swift-index-primitives
//
//  Created by Coen ten Thije Boonkkamp on 27/01/2026.
//

// MARK: - UnsafeMutableRawPointer + Index

extension UnsafeMutableRawPointer {
    /// Allocates uninitialized memory with typed count and alignment.
    @inlinable
    public static func allocate(
        count: Index_Primitives.Index<UInt8>.Count,
        alignment: Index_Primitives.Index<UInt8>.Count
    ) -> Self {
        Self.allocate(byteCount: Int(count.rawValue), alignment: Int(alignment.rawValue))
    }

    /// Initializes memory as the specified type with a repeated value.
    @inlinable
    @discardableResult
    public func initializeMemory<T>(
        as type: T.Type,
        repeating value: T,
        count: Index_Primitives.Index<T>.Count
    ) -> UnsafeMutablePointer<T> {
        unsafe self.initializeMemory(as: type, repeating: value, count: Int(count.rawValue))
    }

    /// Initializes memory as the specified type from a source buffer.
    @inlinable
    @discardableResult
    public func initializeMemory<T>(
        as type: T.Type,
        from source: UnsafePointer<T>,
        count: Index_Primitives.Index<T>.Count
    ) -> UnsafeMutablePointer<T> {
        unsafe self.initializeMemory(as: type, from: source, count: Int(count.rawValue))
    }

    /// Initializes memory by moving values from a source.
    @inlinable
    @discardableResult
    public func moveInitializeMemory<T>(
        as type: T.Type,
        from source: UnsafeMutablePointer<T>,
        count: Index_Primitives.Index<T>.Count
    ) -> UnsafeMutablePointer<T> {
        unsafe self.moveInitializeMemory(as: type, from: source, count: Int(count.rawValue))
    }

    /// Binds the memory to the specified type with a typed capacity.
    @inlinable
    @discardableResult
    public func bindMemory<T>(
        to type: T.Type,
        capacity: Index_Primitives.Index<T>.Count
    ) -> UnsafeMutablePointer<T> {
        unsafe self.bindMemory(to: type, capacity: Int(capacity.rawValue))
    }

    /// Returns a pointer offset by the specified typed byte offset.
    @inlinable
    public func advanced(
        by offset: Index_Primitives.Index<UInt8>.Offset
    ) -> Self {
        unsafe self.advanced(by: offset.rawValue)
    }

    /// Copies bytes from a source with a typed byte count.
    @inlinable
    public func copyMemory(
        from source: UnsafeRawPointer,
        count: Index_Primitives.Index<UInt8>.Count
    ) {
        unsafe self.copyMemory(from: source, byteCount: Int(count.rawValue))
    }
}
