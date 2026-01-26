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

public import Affine_Primitives
@_spi(Internal) public import Identity_Primitives

/// A phantom-typed index for type-safe collection access.
///
/// `Index<Element>` wraps `Affine.Discrete.Position` with a phantom type
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
public typealias Index<Element: ~Copyable> = Tagged<Element, Affine.Discrete.Position>

// MARK: - Index Construction

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {

    public static var zero: Self { .init(__unchecked: (), 0) }

    /// The underlying position.
    @inlinable
    public var position: Affine.Discrete.Position { rawValue }

    /// Construct from a validated position.
    @inlinable
    public init(_ position: Affine.Discrete.Position) {
        self.init(__unchecked: (), position)
    }

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
        self.init(__unchecked: (), other.rawValue.rawValue)
    }

    /// Construct from an integer, throwing if negative.
    ///
    /// - Parameter position: The position value. Must be non-negative.
    /// - Throws: `Error.negativePosition` if position is negative.
    @inlinable
    public init(_ position: Int) throws(Error) {
        do {
            let position = try Affine.Discrete.Position(position)
            self.init(__unchecked: (), position)
        } catch {
            throw .negativePosition(position)
        }
    }

    /// Unchecked construction.
    ///
    /// - Warning: No validation is performed. Use only when the value
    ///   is known to be non-negative.
    @inlinable
    public init(__unchecked: Void, _ position: Int) {
        self.init(__unchecked: (), Affine.Discrete.Position(__unchecked: (), position))
    }
}

// MARK: - Index.Error

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Error type for Index construction.
    public enum Error: Swift.Error, Hashable, Sendable {
        case negativePosition(Int)
    }
}



// MARK: - CustomStringConvertible

extension Tagged: @retroactive CustomStringConvertible
where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    public var description: String {
        "Index<\(Tag.self)>(\(rawValue.rawValue))"
    }
}
