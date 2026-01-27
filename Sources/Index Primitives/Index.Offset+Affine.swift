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

extension Tagged where RawValue == Affine.Discrete.Vector, Tag: ~Copyable {
    /// Creates an offset representing the displacement from the origin to the given position.
    ///
    /// This is the canonical affine decomposition: `position = origin + offset`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let index = Index<Int32>(5)
    /// let offset = try Index<Int32>.Offset(index)  // displacement 5 from origin
    /// let byteOffset = offset * Affine.Discrete.Ratio<Int32, UInt8>(4)  // 20 bytes
    /// ```
    ///
    /// - Parameter index: The index position to decompose.
    /// - Throws: `Affine.Discrete.Vector.Error.unrepresentable` if the position
    ///   exceeds `Int.max` and cannot be represented as a signed displacement.
    @inlinable
    public init(
        _ index: Tagged<Tag, Ordinal.Position>
    ) throws(Affine.Discrete.Vector.Error) {
        self = try index - .zero
    }
}
