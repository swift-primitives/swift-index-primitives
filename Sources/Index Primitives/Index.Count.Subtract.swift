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

public import Property_Primitives
@_spi(Internal) import Identity_Primitives

// MARK: - Subtract Tag and Accessor

extension Tagged.Count where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// Tag for subtraction operations.
    public enum Subtract {}

    /// Access to subtraction operations.
    ///
    /// ```swift
    /// let remaining = size.subtract.saturating(dropCount)
    /// let exact = try size.subtract.exact(dropCount)
    /// ```
    @inlinable
    public var subtract: Property<Subtract, Self> {
        Property(self)
    }
}

// MARK: - Subtraction Operations

extension Property {
    /// Saturating subtraction: returns `max(0, self - other)`.
    @inlinable
    public func saturating<T: ~Copyable>(_ other: Base) -> Base
    where Tag == Tagged<T, Ordinal.Position>.Count.Subtract,
          Base == Tagged<T, Ordinal.Position>.Count {
        Base(base.count.subtract.saturating(other.count))
    }

    /// Exact subtraction: returns `self - other` or throws if negative.
    @inlinable
    public func exact<T: ~Copyable>(_ other: Base) throws(Cardinal.Count.Error) -> Base
    where Tag == Tagged<T, Ordinal.Position>.Count.Subtract,
          Base == Tagged<T, Ordinal.Position>.Count {
        Base(try base.count.subtract.exact(other.count))
    }

    @inlinable
    public func callAsFunction<T: ~Copyable>(_ other: Base) throws(Cardinal.Count.Error) -> Base
    where Tag == Tagged<T, Ordinal.Position>.Count.Subtract,
          Base == Tagged<T, Ordinal.Position>.Count {
        try self.exact(other)
    }
}
