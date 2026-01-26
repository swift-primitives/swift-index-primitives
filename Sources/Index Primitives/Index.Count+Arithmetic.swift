//
//  File.swift
//  swift-index-primitives
//
//  Created by Coen ten Thije Boonkkamp on 24/01/2026.
//

import Affine_Primitives
@_spi(Internal) import Identity_Primitives

// MARK: - Arithmetic

extension Tagged.Count where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Adds two counts.
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.count + rhs.count)
    }

    /// Subtracts one count from another.
    ///
    /// - Returns: The difference, or `nil` if the result would be negative.
    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self? {
        (lhs.count - rhs.count).map(Self.init)
    }
}

extension Tagged.Count where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Multiplies a count by an integer.
    ///
    /// - Throws: `Affine.Discrete.Count.Error.negativeValue` if the result would be negative.
    @inlinable
    public static func * (lhs: Self, rhs: Int) throws(Affine.Discrete.Count.Error) -> Self {
        let result = lhs.rawValue * rhs
        guard result >= 0 else {
            throw .negativeValue(result)
        }
        return Self(__unchecked: (), result)
    }

    /// Multiplies an integer by a count.
    ///
    /// - Throws: `Affine.Discrete.Count.Error.negativeValue` if the result would be negative.
    @inlinable
    public static func * (lhs: Int, rhs: Self) throws(Affine.Discrete.Count.Error) -> Self {
        let result = lhs * rhs.rawValue
        guard result >= 0 else {
            throw .negativeValue(result)
        }
        return Self(__unchecked: (), result)
    }
}

// MARK: - Compound Assignment

extension Tagged.Count where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Increments the count by another count.
    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Decrements the count by another count.
    ///
    /// - Throws: `Affine.Discrete.Count.Error.negativeValue` if result would be negative.
    @inlinable
    public static func -= (lhs: inout Self, rhs: Self) throws(Affine.Discrete.Count.Error) {
        guard let result = lhs - rhs else {
            throw .negativeValue(lhs.rawValue - rhs.rawValue)
        }
        lhs = result
    }
}
