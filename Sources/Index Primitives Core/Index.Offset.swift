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

// MARK: - Index.Offset (Tagged Typealias)

extension Tagged where RawValue == Ordinal, Tag: ~Copyable {
    /// The displacement type for this index.
    ///
    /// Wraps `Affine.Discrete.Vector` to maintain phantom type safety.
    ///
    /// ## Semantic Model
    ///
    /// An offset is the result of subtracting two indices:
    /// - `index2 - index1 → offset`
    /// - `index1 + offset → index2`
    ///
    /// ## Tagged Functor
    ///
    /// As a Tagged typealias, `Index.Offset` gains:
    /// - `retag(_:)` for zero-cost cross-domain conversion
    /// - `map(_:)` for value transformation
    /// - Automatic `Equatable`, `Hashable`, `Comparable`, `Sendable` conformances
    ///
    /// ## Example
    ///
    /// ```swift
    /// let forward = Index<Bit>.Offset(5)
    /// let backward = Index<Bit>.Offset(-3)
    /// let combined = forward + backward  // Offset(2)
    ///
    /// // Cross-domain conversion via retag
    /// let byteOffset: Index<Byte>.Offset = forward.retag(Byte.self)
    /// ```
    public typealias Offset = Tagged<Tag, Affine.Discrete.Vector>
}
