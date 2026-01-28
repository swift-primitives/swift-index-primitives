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

public import Ordinal_Primitives
@_spi(Internal) public import Identity_Primitives

/// A phantom-typed index for type-safe collection access.
///
/// `Index<Element>` wraps `Ordinal.Position` with a phantom type
/// that prevents indices from different collections being confused.
///
/// ## Type Safety
///
/// ```swift
/// let bitIndex: Index<Bit> = try Index(5)
/// let byteIndex: Index<Byte> = try Index(5)
/// // bitIndex == byteIndex  // Compile error - different types
/// ```
///
/// ## Arithmetic
///
/// Index supports affine arithmetic with `Index<Element>.Offset`:
///
/// ```swift
/// let idx: Index<Bit> = try Index(5)
/// let offset = Index<Bit>.Offset(3)
/// let newIdx = try idx + offset  // Index<Bit> at position 8
/// let distance = newIdx - idx    // Offset of 3
/// ```
public typealias Index<Element: ~Copyable> = Tagged<Element, Ordinal.Position>

// MARK: - Index Construction

extension Tagged where RawValue == Ordinal.Position, Tag: ~Copyable {
    /// The underlying position.
    @inlinable
    public var position: Ordinal.Position { rawValue }

    /// The zero index.
    public static var zero: Self { .init(__unchecked: (), .zero) }

    // MARK: - Cross-Domain Retagging

    /// Creates an index by retagging from another tag domain.
    ///
    /// This is a total operation - retagging preserves the position value
    /// and cannot fail. Use this to convert indices between different
    /// phantom-typed domains that share the same underlying position space.
    ///
    /// - Parameter other: An index from a different tag domain.
    @inlinable
    public init<Other: ~Copyable>(_ other: Tagged<Other, RawValue>) {
        self.init(__unchecked: (), other.rawValue)
    }

    /// Construct from an integer, throwing if negative.
    ///
    /// - Parameter position: The position value. Must be non-negative.
    /// - Throws: `Ordinal.Position.Error.negativeSource` if position is negative.
    @inlinable
    public init(_ position: Int) throws(Ordinal.Position.Error) {
        self.init(__unchecked: (), try Ordinal.Position(position))
    }
}

// MARK: - CustomStringConvertible

extension Tagged: @retroactive CustomStringConvertible
where RawValue == Ordinal.Position, Tag: ~Copyable {
    public var description: String {
        "Index<\(Tag.self)>(\(rawValue.rawValue))"
    }
}
