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

extension Tagged where RawValue == Cardinal, Tag: ~Copyable {
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
    where Tag == Tagged<T, Cardinal>.Subtract,
          Base == Tagged<T, Cardinal> {
        Base(__unchecked: (), base.rawValue.subtract.saturating(other.rawValue))
    }

    /// Exact subtraction: returns `self - other` or throws if negative.
    @inlinable
    public func exact<T: ~Copyable>(_ other: Base) throws(Cardinal.Error) -> Base
    where Tag == Tagged<T, Cardinal>.Subtract,
          Base == Tagged<T, Cardinal> {
        Base(__unchecked: (), try base.rawValue.subtract.exact(other.rawValue))
    }

    @inlinable
    public func callAsFunction<T: ~Copyable>(_ other: Base) throws(Cardinal.Error) -> Base
    where Tag == Tagged<T, Cardinal>.Subtract,
          Base == Tagged<T, Cardinal> {
        try self.exact(other)
    }
}
