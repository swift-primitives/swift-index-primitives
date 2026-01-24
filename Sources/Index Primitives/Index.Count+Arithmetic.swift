//
//  File.swift
//  swift-index-primitives
//
//  Created by Coen ten Thije Boonkkamp on 24/01/2026.
//

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
    @inlinable
    public static func * (lhs: Self, rhs: Int) -> Self {
        Self(__unchecked: lhs.rawValue * rhs)
    }
    
    @inlinable
    public static func * (lhs: Int, rhs: Self) -> Self {
        Self(__unchecked: lhs * rhs.rawValue)
    }
}
