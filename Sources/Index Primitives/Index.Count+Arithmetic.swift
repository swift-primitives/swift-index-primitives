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

// MARK: - Count from Offset Conversion

extension Tagged.Count where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// Creates a count from a non-negative offset.
    ///
    /// This is the canonical conversion from `Offset` to `Count`, validating that
    /// the offset is non-negative (since `Count` represents a magnitude).
    ///
    /// - Parameter offset: The offset (must be non-negative).
    /// - Throws: `Cardinal.Count.Error.negativeSource` if offset is negative.
    @inlinable
    public init(_ offset: Tagged<Tag, RawValue>.Offset) throws(Cardinal.Count.Error) {
        guard offset.rawValue >= 0 else {
            throw .negativeSource(offset.rawValue)
        }
        self.init(__unchecked: (), offset.rawValue)
    }

    /// Creates a count from an offset without validation.
    ///
    /// - Parameter offset: The offset (must be non-negative).
    /// - Warning: No validation is performed. Use only when the offset is known
    ///   to be non-negative, such as after subtracting indices where `end >= start`.
    @inlinable
    public init(__unchecked: Void, _ offset: Tagged<Tag, RawValue>.Offset) {
        assert(offset.rawValue >= 0, "Offset must be non-negative for unchecked Count conversion")
        self.init(__unchecked: (), offset.rawValue)
    }
}

// MARK: - Arithmetic

extension Tagged.Count where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// Adds two counts (trapping on overflow).
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.count + rhs.count)
    }
}

extension Tagged.Count where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// Multiplies a count by an unsigned integer.
    @inlinable
    public static func * (lhs: Self, rhs: UInt) -> Self {
        Self(Cardinal.Count(lhs.count.rawValue * rhs))
    }

    /// Multiplies an unsigned integer by a count.
    @inlinable
    public static func * (lhs: UInt, rhs: Self) -> Self {
        Self(Cardinal.Count(lhs * rhs.count.rawValue))
    }
}

// MARK: - Compound Assignment

extension Tagged.Count where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// Increments the count by another count.
    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
