// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// Hoisted type for `Index.Safe`.
///
/// Accessor for safe index operations. All subscripts return `Optional`,
/// returning `nil` for out-of-bounds access instead of trapping.
///
/// Accessed via the `.safe` property on any `Collection`.
///
/// - Note: This type is hoisted to module level with `__` prefix because
///   `Index` is a namespace enum. The canonical name is `Index.Safe` (via typealias).
public struct __IndexSafe<Base: Collection> {
    @usableFromInline
    let base: Base

    @usableFromInline
    init(_ base: Base) {
        self.base = base
    }
}

extension __IndexSafe: Sendable where Base: Sendable {}

// MARK: - Typealias

extension Index {
    /// Safe index accessor for collections.
    ///
    /// All subscripts return `Optional`, returning `nil` for out-of-bounds
    /// access instead of trapping.
    ///
    /// - SeeAlso: ``__IndexSafe``
    public typealias Safe<Base: Collection> = __IndexSafe<Base>
}
