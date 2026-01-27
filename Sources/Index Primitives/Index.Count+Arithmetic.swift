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

@_spi(Internal) import Identity_Primitives
import Affine_Primitives

// MARK: - Count from Offset Conversion

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {
    /// Creates a count from a non-negative offset.
    ///
    /// This is the canonical conversion from `Offset` to `Count`, validating that
    /// the offset is non-negative (since `Count` represents a magnitude).
    ///
    /// - Parameter offset: The offset (must be non-negative).
    /// - Throws: `Cardinal.Count.Error.negativeSource` if offset is negative.
    @inlinable
    public init(_ offset: Tagged<Tag, Affine.Discrete.Vector>) throws(Cardinal.Count.Error) {
        guard offset.rawValue.rawValue >= 0 else {
            throw .negativeSource(offset.rawValue.rawValue)
        }
        self.init(__unchecked: (), offset.rawValue.rawValue)
    }

    /// Creates a count from an offset without validation.
    ///
    /// - Parameter offset: The offset (must be non-negative).
    /// - Warning: No validation is performed. Use only when the offset is known
    ///   to be non-negative, such as after subtracting indices where `end >= start`.
    @inlinable
    public init(__unchecked: Void, _ offset: Tagged<Tag, Affine.Discrete.Vector>) {
        assert(offset.rawValue.rawValue >= 0, "Offset must be non-negative for unchecked Count conversion")
        self.init(__unchecked: (), offset.rawValue.rawValue)
    }
}

// MARK: - Arithmetic

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {
    /// Adds two counts (trapping on overflow).
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(__unchecked: (), lhs.rawValue + rhs.rawValue)
    }
}

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {
    /// Multiplies a count by an unsigned integer.
    @inlinable
    public static func * (lhs: Self, rhs: UInt) -> Self {
        Self(__unchecked: (), Cardinal.Count(lhs.rawValue.rawValue * rhs))
    }

    /// Multiplies an unsigned integer by a count.
    @inlinable
    public static func * (lhs: UInt, rhs: Self) -> Self {
        Self(__unchecked: (), Cardinal.Count(lhs * rhs.rawValue.rawValue))
    }
}

// MARK: - Compound Assignment

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {
    /// Increments the count by another count.
    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
