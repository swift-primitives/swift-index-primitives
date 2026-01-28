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

extension Tagged where RawValue == Cardinal, Tag: ~Copyable {
    /// Creates a count from a non-negative offset.
    ///
    /// This is the canonical conversion from `Offset` to `Count`, validating that
    /// the offset is non-negative (since `Count` represents a magnitude).
    ///
    /// - Parameter offset: The offset (must be non-negative).
    /// - Throws: `Cardinal.Error.negativeSource` if offset is negative.
    @inlinable
    public init(_ offset: Tagged<Tag, Affine.Discrete.Vector>) throws(Cardinal.Error) {
        guard offset.rawValue.rawValue >= 0 else {
            throw .negativeSource(offset.rawValue.rawValue)
        }
        self.init(__unchecked: (), Cardinal(UInt(offset.rawValue.rawValue)))
    }

    /// Creates a count from an offset without validation.
    ///
    /// - Parameter offset: The offset (must be non-negative).
    /// - Warning: No validation is performed. Use only when the offset is known
    ///   to be non-negative, such as after subtracting indices where `end >= start`.
    @inlinable
    public init(__unchecked: Void, _ offset: Tagged<Tag, Affine.Discrete.Vector>) {
        assert(offset.rawValue.rawValue >= 0, "Offset must be non-negative for unchecked Count conversion")
        self.init(__unchecked: (), Cardinal(UInt(offset.rawValue.rawValue)))
    }
}
